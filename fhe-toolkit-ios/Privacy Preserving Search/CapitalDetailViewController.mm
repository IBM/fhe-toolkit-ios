/*
* MIT License
*
* Copyright (c) 2020 International Business Machines
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#import "CapitalDetailViewController.h"

#include <iostream>
#include <helib/helib.h>
#include "helayers/hebase/helib/HelibBgvContext.h"
#include <helib/EncryptedArray.h>
#include <helib/ArgMap.h>
#include <NTL/BasicThreadPool.h>

using namespace helayers;
using namespace std;

std::string prependBundlePathOnFilePath(const char *fileName) {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String: fileName] ofType: nil];
    char const *filePath = filepath.UTF8String;
    return filePath;
}


@interface CapitalDetailViewController ()

@end

@implementation CapitalDetailViewController

@synthesize queryCountry, countryLabel, capitalResultLabel, timeGone, logging, loadingScreen;

// Note: These parameters have been chosen to provide fast running times as
// opposed to a realistic security level. As well as negligible security,
// these default parameters result in an algebra with only 10 slots which limits
// the size of both the “keys” and “values” to 10 chars. If you try to use
// bigger “keys” or “values” you will need to choose different parameters
// that give you more slots, otherwise the code will throw an
// "helib::OutOfRangeError" exception.
//
// Commented below there is the parameter "m-130" which will result in an algebra
// with 48 slots, thus allowing for “keys” and “values” up to 48 chars.

// Plaintext prime modulus
unsigned long p = 127;
// Cyclotomic polynomial - defines phi(m)
unsigned long m = 128; // this will give 32 slots
// Hensel lifting (default = 1)
unsigned long r = 1;
// Number of bits of the modulus chain
unsigned long bits = 1000;
// Number of columns of Key-Switching matrix (default = 2 or 3)
unsigned long c = 2;
// Size of NTL thread pool (default =1)
unsigned long nthreads = 12;
// input database file name
string db_filename =  prependBundlePathOnFilePath("countries_dataset.csv");
// debug output (default no debug output)
unsigned long debug = 0;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"query country %@ ", self.queryCountry);
    [self.loadingScreen setHidesWhenStopped:YES];
    [self.loadingScreen startAnimating];
    self.countryLabel.text = [NSString stringWithFormat:@"Country: %@", self.queryCountry];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         NSLog(@"Triggering sample code");
         [self createCapitalQuery];
    });
    [self startTimer];
}

- (void)createCapitalQuery {

    //helib::ArgMap amap;
    //amap.arg("p", p);
    //amap.arg("m", m);
    //amap.arg("debug", debug);
    //amap.arg("nthreads", nthreads);

    // set NTL Thread pool size
    if (nthreads > 1)
      NTL::SetNumThreads(nthreads);
    
     std::cout << "\nBGV Database Lookup Example" << std::endl;
     std::cout << "===========================" << std::endl << std::endl;
     std::cout << "---Initialising HE Environment ... ";
    
    // To setup helib using the hebase layer, let's first
    // copy all configuration params to an HelibConfig object:
    HelibConfig conf;
    conf.p = p;
    conf.m = m;
    conf.r = r;
    conf.L = bits;
    conf.c = c;
    
    // Next we'll initialize a BGV scheme in helib.
    // The following two lines perform full intializiation
    // Including key generation.
    HelibBgvContext he;
    he.init(conf);
    
     // Modify the context, adding primes to the modulus chain
     std::cout  << "Building modulus chain..." << std::endl;
     dispatch_async(dispatch_get_main_queue(), ^(void){
             [self.logging setText:[NSString stringWithFormat:@"Building modulus chain..."]];
     });
    
     string countryName = std::string([self.queryCountry UTF8String]);;
     // Helib-BGV is now ready to start doing some HE work.
     // which we'll do in the follwing function, defined below
     string string_result = run(he, db_filename, countryName, debug);
    
//     helib::buildModChain(context, bits, c);
//
//     // Secret key management
//     std::cout << "\n\tSecret Key ...";
//     // Create a secret key associated with the context
//     helib::SecKey secret_key = helib::SecKey(context);
//     // Generate the secret key
//     secret_key.GenSecKey();
//
//     // Secret key management
//     std::cout << "Creating secret key..." << std::endl;
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Creating secret key..."]];
//     });
//
//
//     std::cout << "Generating key-switching matrices..." << std::endl;
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Generating key-switching matrices..."]];
//     });
//     // Compute key-switching matrices that we need
//     helib::addSome1DMatrices(secret_key);
//
//     // Public key management
//     // Set the secret key (upcast: FHESecKey is a subclass of FHEPubKey)
//     std::cout << "\n\tPublic Key ...";
//     const helib::PubKey& public_key = secret_key;
//
//     // Get the EncryptedArray of the context
//     const helib::EncryptedArray& ea = *(context.ea);
//
//     // Print the context
//     std::cout << std::endl;
//     if (debug)
//       context.zMStar.printout();
//
//    // Print the security level
//    // Note: This will be negligible to improve performance time.
//    std::cout << "\n***Security: " << context.securityLevel()
//              << " (Negligible for this example)" << std::endl;
//
//     // Get the number of slot (phi(m))
//     long nslots = ea.size();
//     std::cout << "\nNumber of slots: " << nslots << std::endl;
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Number of slots: %ld", nslots]];
//     });
//     /* ********** Create the database *********** */
//
//     std::vector<std::pair<std::string, std::string>> address_book = {
//       { "Albania", "Tirana" },
//       { "Andorra", "Andorra la Vella" },
//       { "Austria", "Vienna" },
//       { "Belarus", "Minsk" },
//       { "Belgium", "Brussels" },
//       { "Bosnia and Herzegovina", "Sarajevo" },
//       { "Bulgaria", "Sofia" },
//       { "Croatia", "Zagreb" },
//       { "Czech Republic", "Prague" },
//       { "Denmark", "Copenhagen" },
//       { "Estonia", "Tallinn" },
//       { "Finland", "Helsinki" },
//       { "France", "Paris" },
//       { "Germany", "Berlin" },
//       { "Greece", "Athens" },
//       { "Hungary", "Budapest" },
//       { "Iceland", "Reykjavik" },
//       { "Ireland", "Dublin" },
//       { "Italy", "Rome" },
//       { "Latvia", "Riga" },
//       { "Liechtenstein", "Vaduz" },
//       { "Lithuania", "Vilnius" },
//       { "Luxembourg", "Luxembourg" },
//       { "Malta", "Valletta" },
//       { "Moldova", "Chisinau" },
//       { "Monaco", "Monaco" },
//       { "Montenegro", "Podgorica" },
//       { "Netherlands", "Amsterdam" },
//       { "Norway", "Oslo" },
//       { "Poland", "Warsaw" },
//       { "Portugal", "Lisbon" },
//       { "Romania", "Bucharest" },
//       { "Russia", "Moscow" },
//       { "San Marino", "San Marino" },
//       { "Serbia", "Belgrade" },
//       { "Slovakia", "Bratislava" },
//       { "Slovenia", "Ljubljana" },
//       { "Spain", "Madrid" },
//       { "Sweden", "Stockholm" },
//       { "Switzerland", "Bern" },
//       { "Turkey", "Ankara" },
//       { "Ukraine", "Kiev" },
//       { "United Kingdom; England", "London" }
//     };
//
//     // Convert strings into numerical vectors
//     std::cout << "\n---Initializing the encrypted key,value pair database ("
//               << address_book.size() << " entries)..." << std::endl;
//     std::cout
//         << "\tConverting strings to numeric representation into Ptxt objects ..."
//         << std::endl;
//
//     std::vector<std::pair<helib::Ptxt<helib::BGV>, helib::Ptxt<helib::BGV>>>
//         address_book_ptxt;
//     for (const auto& name_addr_pair : address_book) {
//       if (debug) {
//         std::cout << "\t\tname_addr_pair.first size = "
//                   << name_addr_pair.first.size() << " (" << name_addr_pair.first
//                   << ")"
//                   << "\tname_addr_pair.second size = "
//                   << name_addr_pair.second.size() << " (" << name_addr_pair.second
//                   << ")" << std::endl;
//       }
//
//       helib::Ptxt<helib::BGV> name(context);
//       // std::cout << "\tname size = " << name.size() << std::endl;
//       for (long i = 0; i < name_addr_pair.first.size(); ++i)
//         name.at(i) = name_addr_pair.first[i];
//
//       helib::Ptxt<helib::BGV> addr(context);
//       for (long i = 0; i < name_addr_pair.second.size(); ++i)
//         addr.at(i) = name_addr_pair.second[i];
//       address_book_ptxt.emplace_back(std::move(name), std::move(addr));
//     }
//
//     // Encrypt the address book
//     std::cout << "\tEncrypting the database..." << std::endl;
//     std::vector<std::pair<helib::Ctxt, helib::Ctxt>> encrypted_address_book;
//     for (const auto& name_addr_pair : address_book_ptxt) {
//        helib::Ctxt encrypted_name(public_key);
//        helib::Ctxt encrypted_addr(public_key);
//        public_key.Encrypt(encrypted_name, name_addr_pair.first);
//        public_key.Encrypt(encrypted_addr, name_addr_pair.second);
//        encrypted_address_book.emplace_back(encrypted_name, encrypted_addr);
//     }
//
//    // Print Timers
//
//    std::cout << "\nInitialization Completed - Ready for Queries" << std::endl;
//    std::cout << "--------------------------------------------" << std::endl;
//
//     /** Create the query **/
//     std::string query_string = std::string([self.queryCountry UTF8String]);
//     NSLog(@"CREATED QUERY FOR %@", self.queryCountry);
//     std::cout << "\nQuery in string form: " << query_string << std::endl;
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Creating Encrypted query"]];
//     });
//
//     // Convert query to a numerical vector
//     helib::Ptxt<helib::BGV> query_ptxt(context);
//     for (long i = 0; i < query_string.size(); ++i)
//       query_ptxt[i] = query_string[i];
//
//     // Encrypt the query
//     helib::Ctxt query(public_key);
//     public_key.Encrypt(query, query_ptxt);

//
//     /* ********** Perform the database search *********** */
//
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Searching the Database"]];
//     });
//
//     std::vector<helib::Ctxt> mask;
//     mask.reserve(address_book.size());
//     for (const auto& encrypted_pair : encrypted_address_book) {
//       helib::Ctxt mask_entry = encrypted_pair.first; // Copy of database key
//       mask_entry -= query;                           // Calculate the difference
//       mask_entry.power(p - 1);                       // FLT
//       mask_entry.negate();                           // Negate the ciphertext
//       mask_entry.addConstant(NTL::ZZX(1));           // 1 - mask = 0 or 1
//       // Create a vector of copies of the mask
//       std::vector<helib::Ctxt> rotated_masks(ea.size(), mask_entry);
//       for (int i = 1; i < rotated_masks.size(); i++)
//         ea.rotate(rotated_masks[i], i);             // Rotate each of the masks
//       totalProduct(mask_entry, rotated_masks);      // Multiply each of the masks
//       mask_entry.multiplyBy(encrypted_pair.second); // multiply mask with values
//       mask.push_back(mask_entry);
//     }
//
//     // Aggregate the results into a single ciphertext
//     // Note: This code is for educational purposes and thus we try to refrain
//     // from using the STL and do not use std::accumulate
//     helib::Ctxt value = mask[0];
//     for (int i = 1; i < mask.size(); i++)
//       value += mask[i];
//
//
//     /* ********** Decrypt and print result *********** */
//
//     dispatch_async(dispatch_get_main_queue(), ^(void){
//             [self.logging setText:[NSString stringWithFormat:@"Decrypting the Result"]];
//     });
//
//     helib::Ptxt<helib::BGV> plaintext_result(context);
//     secret_key.Decrypt(plaintext_result, value);
//
//
//     // Convert from ASCII to a string
//     std::string string_result;
//     for (long i = 0; i < plaintext_result.size(); ++i)
//       string_result.push_back(static_cast<long>(plaintext_result[i]));

  //   std::cout << "\nQuery result: " << string_result << std::endl;
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self.logging setText:[NSString stringWithFormat:@"Result:"]];
    //    [self.capitalResultLabel setText:[NSString stringWithFormat:@"Capital: %s", string_result.c_str()]];
        [self.loadingScreen stopAnimating];
        [self.timeTicker invalidate];
    });
}

// Utility function to read <K,V> CSV data from file
vector<pair<string, string>> read_csv(string filename, int maxLen) {
  vector<pair<string, string>> dataset;
  ifstream data_file(filename);

  if (!data_file.is_open())
    throw runtime_error(
        "Error: This example failed trying to open the data file: " + filename +
        "\n           Please check this file exists and try again.");

  vector<string> row;
  string line, entry, temp;

  if (data_file.good()) {
    // Read each line of file
    while (getline(data_file, line)) {
      row.clear();
      stringstream ss(line);
      //grab the next line in the csv
      getline(ss, entry);
      size_t pos = 0;
      //split the first part by "," which should be the country
      std::string delimiter = ",";
      //find the pos of the first ,
      pos = entry.find(delimiter);
      //grab all the characters in front of the first ,
      std::string token = entry.substr(0, pos);
      //store it in row[0]
      row.push_back(token);
      //add the size of the , char to the position so we know where the capital starts
      pos = pos + delimiter.length();
      //grab the rest of the row as the capital
      token = entry.substr(pos, string::npos);
      //store it as row[1]
      row.push_back(token);
      if (row[0].size() > maxLen)
        throw runtime_error("Country name " + row[0] + " too long");
      if (row[1].size() > maxLen)
        throw runtime_error("Capital name " + row[1] + " too long");

      // Add key value pairs to dataset
      dataset.push_back(make_pair(row[0], row[1]));
    }
  }

  data_file.close();
  return dataset;
}

string run(HeContext& he, const string& db_filename, const std::string& countryName, bool debug) {
    // The run function receives an abstract HeContext class.
    // Therefore the code below is oblivious to a particular HE scheme
    // implementation.

    // First let's print general information on our library and scheme.
    // This will print their names, and the configuraton details.
    he.printSignature();
    
    // However we do have some requirements that we can
    // assert exists:
    // We require the plaintext to be over modular arithmetic.
    // We'll rely on that later.
    //always_assert(he.getTraits().getIsModularArithmetic());
    // Since we store ascii codes, we need it at least to be able
    // to handle the numbers 0...127
    //always_assert(he.getTraits().getArithmeticModulus() >= 127);

    // Next, print the security level
    // Note: This will be negligible to improve performance time.
    cout << "\n***Security Level: " << he.getSecurityLevel()
         << " *** Negligible for this example ***" << endl;

    // Let's also print the number of slots.
    // Each ciphertext will have this many slots.
    cout << "\nNumber of slots: " << he.slotCount() << endl;
    
    // Now we'll read in the database (in cleartext).
    // This function we'll make sure no string is longer than he.slotCount()
    vector<pair<string, string>> country_db = read_csv(db_filename, he.slotCount());
    
    
    
    return  nil;
}

- (void)startTimer {
    self.timeTicker = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTimerActivity) userInfo:nil repeats:YES];
}

- (void)showTimerActivity {
    
    int currentTime = self.timeGone.text.intValue;
    float newTime = float(currentTime + 1);
    [self.timeGone setText:[NSString stringWithFormat:@"%.1f", newTime]];
}

@end
