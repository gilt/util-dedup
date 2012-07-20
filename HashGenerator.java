import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.Charset;

/**
 * Wrapper class providing a simple API to SHA-512 hash algorithm.
 */
public class HashGenerator {

    private static final String ALGORITHM = "SHA-512";
    private static final Charset UTF8 = Charset.forName("UTF-8");

    private final String salt;

    /**
     * @param salt Each value that is hashed will be prefixed with this salt.
     */
    public HashGenerator(String salt) {
        this.salt = salt;
    }

    /**
     * Returns the SHA-512 hash of the provided string. String is assumed to be in UTF-8.
     *
     * @param value Cannot be null
     */
    public String hash(String value) {
        if (value == null) {
            throw new IllegalArgumentException("Value to hash cannot be null");
        }
        String saltedValue = salt + value;
        return hash(saltedValue.getBytes(UTF8));
    }

    /**
     * Returns the SHA-512 hash of the provided string
     */
    public String hash(byte[] input) {
        byte[] bytes = hashBytes(input);

        StringBuilder buffer = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(b & 0xFF);
            if (hex.length() < 2) {
                buffer.append("0");
            }
            buffer.append(hex);
        }
        return buffer.toString();
    }

    private byte[] hashBytes(byte[] bytes) {
        try {
            MessageDigest md = MessageDigest.getInstance(ALGORITHM);
            md.update(bytes);
            return md.digest();
        } catch (NoSuchAlgorithmException e) {
            throw new Error("Missing standard digest algorithm: " + ALGORITHM, e);
        }
    }
}
