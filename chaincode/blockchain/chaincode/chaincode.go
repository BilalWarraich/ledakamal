package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-protos-go/peer"
	shell "github.com/ipfs/go-ipfs-api"
)

// Donor represents the structure of a donor.
type Donor struct {
	DonorID          string `json:"donorId"`
	Name             string `json:"name"`
	Gender           string `json:"gender"`
	BloodGroup       string `json:"bloodGroup"`
	LastDonationDate string `json:"lastDonationDate"`
	AadharNumber     string `json:"aadharNumber"`
	Mobile           string `json:"mobile"`
	Email            string `json:"email"`
	Height           int    `json:"height"`
	Weight           int    `json:"weight"`
	State            string `json:"state"`
	District         string `json:"district"`
	Consent          bool   `json:"consent"`
}

// DonorReference holds the reference to a donor's data on IPFS.
type DonorReference struct {
	DonorID  string `json:"donorId"`
	IPFSHash string `json:"ipfsHash"`
}

// SmartContract defines the chaincode class
type SmartContract struct {
}

// Init is called during chaincode instantiation to initialize any data.
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

// Invoke is called per transaction on the chaincode.
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) peer.Response {
	function, args := APIstub.GetFunctionAndParameters()

	if function == "createDonor" {
		return s.createDonor(APIstub, args)
	} else if function == "queryDonor" {
		return s.queryDonor(APIstub, args)
	}

	return shim.Error("Invalid function name.")
}

// createDonor is a transaction that adds a new donor to the ledger.
func (s *SmartContract) createDonor(APIstub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 13 {
		return shim.Error("Incorrect number of arguments. Expecting 13")
	}

	// Parse donor data
	height := atoi(args[8])
	weight := atoi(args[9])
	consent := atob(args[12])

	// Check donor eligibility
	if !isEligible(args[4], height, weight) {
		return shim.Error("Donor does not meet eligibility criteria")
	}

	// Initialize the donor with input data
	donor := Donor{
		DonorID:          args[0],
		Name:             args[1],
		Gender:           args[2],
		BloodGroup:       args[3],
		LastDonationDate: args[4],
		AadharNumber:     args[5],
		Mobile:           args[6],
		Email:            args[7],
		Height:           height,
		Weight:           weight,
		State:            args[10],
		District:         args[11],
		Consent:          consent,
	}

	// Marshal non-sensitive data to JSON
	nonSensitiveData := map[string]interface{}{
		"height":   donor.Height,
		"weight":   donor.Weight,
		"state":    donor.State,
		"district": donor.District,
	}

	nonSensitiveJSON, err := json.Marshal(nonSensitiveData)
	if err != nil {
		return shim.Error("Failed to marshal non-sensitive data: " + err.Error())
	}

	// Store non-sensitive data on IPFS
	ipfsHash := storeOnIPFS(nonSensitiveJSON)
	if ipfsHash == "" {
		return shim.Error("Failed to store non-sensitive data on IPFS")
	}

	// Marshal sensitive data to JSON
	sensitiveData := map[string]interface{}{
		"aadharNumber": donor.AadharNumber,
		"mobile":       donor.Mobile,
		"email":        donor.Email,
	}

	sensitiveJSON, err := json.Marshal(sensitiveData)
	if err != nil {
		return shim.Error("Failed to marshal sensitive data: " + err.Error())
	}

	// Store sensitive data in PDC
	err = APIstub.PutPrivateData("collectionDonorSensitive", donor.DonorID, sensitiveJSON)
	if err != nil {
		return shim.Error("Failed to store sensitive data in PDC: " + err.Error())
	}

	// Create DonorReference and store on blockchain
	donorReference := DonorReference{
		DonorID:  donor.DonorID,
		IPFSHash: ipfsHash,
	}

	donorReferenceJSON, err := json.Marshal(donorReference)
	if err != nil {
		return shim.Error("Failed to marshal donor reference: " + err.Error())
	}

	err = APIstub.PutState(donor.DonorID, donorReferenceJSON)
	if err != nil {
		return shim.Error("Failed to store donor reference on blockchain: " + err.Error())
	}

	return shim.Success([]byte("Donor created successfully"))
}

// queryDonor retrieves the donor information based on the DonorID.
func (s *SmartContract) queryDonor(APIstub shim.ChaincodeStubInterface, args []string) peer.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	donorID := args[0]

	// Retrieve DonorReference from the blockchain
	donorReferenceJSON, err := APIstub.GetState(donorID)
	if err != nil {
		return shim.Error("Failed to retrieve donor reference: " + err.Error())
	} else if donorReferenceJSON == nil {
		return shim.Error("Donor reference not found")
	}

	donorReference := DonorReference{}
	err = json.Unmarshal(donorReferenceJSON, &donorReference)
	if err != nil {
		return shim.Error("Failed to unmarshal donor reference: " + err.Error())
	}

	// Retrieve non-sensitive data from IPFS
	nonSensitiveJSON := retrieveFromIPFS(donorReference.IPFSHash)
	if nonSensitiveJSON == nil {
		return shim.Error("Failed to retrieve non-sensitive data from IPFS")
	}

	// Try to retrieve sensitive data from PDC
	sensitiveJSON, err := APIstub.GetPrivateData("collectionDonorSensitive", donorID)
	if err != nil {
		// Log the error but proceed with non-sensitive data only
		fmt.Printf("Failed to retrieve sensitive data from PDC: %v. Returning non-sensitive data only.\n", err)
	}

	// Initialize Donor struct with non-sensitive data
	donor := Donor{
		DonorID: donorID,
	}

	err = json.Unmarshal(nonSensitiveJSON, &donor)
	if err != nil {
		return shim.Error("Failed to unmarshal non-sensitive data: " + err.Error())
	}

	// Only add sensitive data if it's available
	if sensitiveJSON != nil {
		err = json.Unmarshal(sensitiveJSON, &donor)
		if err != nil {
			return shim.Error("Failed to unmarshal sensitive data: " + err.Error())
		}
	} else {
		fmt.Println("Sensitive data not available, returning non-sensitive data only")
	}

	// Return donor data
	donorJSON, err := json.Marshal(donor)
	if err != nil {
		return shim.Error("Failed to marshal donor data: " + err.Error())
	}

	return shim.Success(donorJSON)
}

// isEligible checks whether the donor meets the eligibility criteria.
func isEligible(lastDonationDate string, height int, weight int) bool {
	fmt.Printf("Checking eligibility: lastDonationDate=%s, height=%d, weight=%d\n", lastDonationDate, height, weight)
	if weight < 110 || height < 60 {
		fmt.Println("Donor does not meet height or weight criteria")
		return false
	}
	dateLayout := "2006-01-02"
	lastDonation, err := time.Parse(dateLayout, lastDonationDate)
	if err != nil {
		fmt.Printf("Error parsing date: %v\n", err)
		return false
	}
	daysSinceLastDonation := time.Since(lastDonation).Hours() / 24
	fmt.Printf("Days since last donation: %f\n", daysSinceLastDonation)
	if daysSinceLastDonation < 56 {
		fmt.Println("Donor does not meet last donation date criteria")
		return false
	}
	fmt.Println("Donor meets all eligibility criteria")
	return true
}
func atoi(str string) int {
	// Remove any double quotes from the string
	str = strings.Trim(str, "\"")
	value, _ := strconv.Atoi(str)
	return value
}

func atob(str string) bool {
	// Remove any double quotes from the string
	str = strings.Trim(str, "\"")

	value, _ := strconv.ParseBool(str)
	return value
}

// Placeholder for IPFS interaction
func storeOnIPFS(data []byte) string {
	// Connect to the local IPFS node
	sh := shell.NewShell("ipfs_container:5001")

	// Store the data on IPFS
	cid, err := sh.Add(bytes.NewReader(data))
	if err != nil {
		fmt.Printf("Error storing data on IPFS: %s", err)
		fmt.Printf("Data to be stored: %s\n", string(data))
		return ""
	}
	fmt.Printf("Data to be stored: %s\n", cid)

	return cid
}

// Placeholder for IPFS retrieval
func retrieveFromIPFS(hash string) []byte {
	// Connect to the local IPFS node
	sh := shell.NewShell("ipfs_container:5001")

	// Retrieve the data from IPFS using the hash
	data, err := sh.Cat(hash)
	if err != nil {
		fmt.Printf("Error retrieving data from IPFS: %s", err)
		return nil
	}

	// Read the data into a byte slice
	buf := new(bytes.Buffer)
	buf.ReadFrom(data)

	return buf.Bytes()
}

func main() {
	// Start the chaincode process
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error starting SmartContract chaincode: %s", err)
	}
}
