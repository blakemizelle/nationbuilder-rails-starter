module OAuth
  class PkceGenerator
    def self.generate
      code_verifier = generate_code_verifier
      code_challenge = generate_code_challenge(code_verifier)
      
      {
        code_verifier: code_verifier,
        code_challenge: code_challenge
      }
    end
    
    def self.generate_code_verifier
      # Generate a cryptographically random string
      # Length: 43-128 characters (we use 43)
      # Characters: [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"
      SecureRandom.urlsafe_base64(32)
    end
    
    def self.generate_code_challenge(code_verifier)
      # SHA256 hash of the code verifier, base64url encoded without padding
      digest = Digest::SHA256.digest(code_verifier)
      Base64.urlsafe_encode64(digest, padding: false)
    end
  end
end
