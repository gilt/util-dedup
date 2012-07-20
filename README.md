Created to simplify how we compare gilt's membership list with other
companies list. The idea is to prevent sharing the full email list of
all gilt members, and instead share a hash of those email lists (and a
salt) with the other company.

Scripts here are intended to require ZERO dependencies, work cross
platform, and be simple to use.

    javac *.java

    # Create a test file. Note that the dedup will lowercase / trim
    # white space for each ilne in the file.
    echo "michael@gilt.com" > emails.txt
    echo "MICHAEL@gilt.com" >> emails.txt
    echo " michael@gilt.com " >> emails.txt
    echo "mike@gilt.com " >> emails.txt
    echo "mb@gilt.com " >> emails.txt

    # Create a salt. Takes an optional argument for the length of
    # the salt (default is 128 bytes)
    java CreateSalt > salt.txt

    # Using the provided salt, reads the file emails.txt and creates a
    # SHA-512 hash of every line in the file.
    java HashFile salt.txt emails.txt > hashed.txt

    # This method will display every line in emails.txt where the
    # SHA-512 hash of the salt + line exists in the file
    # hashed.txt. Requires a larger heap as we first will read the
    # entire contents of hashed.txt into RAM
    java -Xmx5g FindHashes salt.txt emails.txt hashed.txt
