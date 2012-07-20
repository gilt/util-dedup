import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.io.UnsupportedEncodingException;

public class HashGenerator {

    private static final String ALGORITHM = "SHA-512";

    private final String salt;

    public HashGenerator(String salt) {
        this.salt = salt;
    }

    public String hash(String value) {
        String saltedValue = salt + value;
        try {
            return hash(saltedValue.getBytes("UTF-8"));
        } catch (UnsupportedEncodingException e) {
            throw new Error("Missing standard character set UTF-8", e);
        }
    }

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
