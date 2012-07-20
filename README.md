Created to simplify how we compare gilt's membership list with other
companies list. The idea is to prevent sharing the full email list of
all gilt members, and instead share a hash of those email lists (and a
salt) with the other company.

Scripts here are intended to require ZERO dependencies, work cross
platform, and be simple to use.

    javac *.java

    echo "michael@gilt.com" > test.txt
    echo "MICHAEL@gilt.com" >> test.txt
    echo " michael@gilt.com " >> test.txt
    echo "list@gilt.com " >> test.txt

    java CreateSalt > s.txt
    java HashFile s.txt test.txt > h.txt
    java -Xmx5g FindHashes s.txt test.txt h.txt
