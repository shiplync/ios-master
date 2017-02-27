ios-impaqd
==========

IOS app for Impaqd

## Push certificate creation instructions: 
NOTE: File names in this example are arbitrary

1. Create and download new push certificate in apple developer console. In the process, you will need to "Request a certificate from a certificate authority" using the Keychain Access app (OSX). 
1. Export the private key (from above step) as `ImpaqdDemoPushProd.p12`. Use an appropriate password and save it in the password file. 
1. Run `openssl x509 -in aps_production.cer -inform der -out ImpaqdDemoPushProdCert.pem`
1. Run `openssl pkcs12 -nocerts -out ImpaqdDemoPushProd.pem -in ImpaqdDemoPushProd.p12 -nodes`
1. Run `cat ImpaqdDemoPushProdCert.pem ImpaqdDemoPushProd.pem > pushdemoprod.pem`
1. Add the .pem files to the appropriate directory in the `certificates` directory on the backend. 

### Development Set Up

* Install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12). Latetest version (as of this writing) is 6.2

* Clone the (repo)[https://github.com/traansmission/ios]

* Install ruby (bundler)[http://bundler.io/v1.3/gemfile.html]
```bash
gem install bundler
```

* Install project gems
```bash
bundle install
```

* Install project pods
```bash
pod install
```

* You're good to go! Make sure you open the _.xcworkspace_ file in Xcode.
