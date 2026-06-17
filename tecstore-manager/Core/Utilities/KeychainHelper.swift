// Wrapper minimalista sobre el Keychain de iOS para guardar datos sensibles de forma segura.
import Foundation
import Security

final class KeychainHelper {

    // MARK: - Singleton

    static let shared = KeychainHelper()
    private init() {}

    // MARK: - Private

    private let service = Bundle.main.bundleIdentifier ?? "com.tecsup.tecstore-manager"

    // MARK: - Save

    func save(_ data: Data, forKey key: String) {
        delete(forKey: key)

        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecValueData:   data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("KeychainHelper: save failed for key '\(key)' — OSStatus \(status)")
        }
    }

    // MARK: - Load

    func load(forKey key: String) -> Data? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrService:      service,
            kSecAttrAccount:      key,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    // MARK: - Delete

    func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - String Convenience

extension KeychainHelper {

    func save(_ string: String, forKey key: String) {
        guard let data = string.data(using: .utf8) else { return }
        save(data, forKey: key)
    }

    func loadString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
