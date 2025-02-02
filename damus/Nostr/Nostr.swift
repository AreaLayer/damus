//
//  Nostr.swift
//  damus
//
//  Created by William Casarin on 2022-04-07.
//

import Foundation

struct Profile: Codable {
    var value: [String: String]
    
    init (name: String?, display_name: String?, about: String?, picture: String?, banner: String?, website: String?, lud06: String?, lud16: String?, nip05: String?) {
        self.value = [:]
        self.name = name
        self.display_name = display_name
        self.about = about
        self.picture = picture
        self.banner = banner
        self.website = website
        self.lud06 = lud06
        self.lud16 = lud16
        self.nip05 = nip05
    }
    
    var display_name: String? {
        get { return value["display_name"]; }
        set(s) { value["display_name"] = s }
    }
    
    var name: String? {
        get { return value["name"]; }
        set(s) { value["name"] = s }
    }
    
    var about: String? {
        get { return value["about"]; }
        set(s) { value["about"] = s }
    }
    
    var picture: String? {
        get { return value["picture"]; }
        set(s) { value["picture"] = s }
    }
    
    var banner: String? {
        get { return value["banner"]; }
        set(s) { value["banner"] = s }
    }
    
    var website: String? {
        get { return value["website"]; }
        set(s) { value["website"] = s }
    }
    
    var website_url: URL? {
        return self.website.flatMap { URL(string: $0) }
    }
    
    var lud06: String? {
        get { return value["lud06"]; }
        set(s) { value["lud06"] = s }
    }
    
    var lud16: String? {
        get { return value["lud16"]; }
        set(s) { value["lud16"] = s }
    }
    
    var lnurl: String? {
        guard let addr = lud06 ?? lud16 else {
            return nil;
        }
        
        if addr.contains("@") {
            return lnaddress_to_lnurl(addr);
        }
        
        return addr;
    }
    
    var nip05: String? {
        get { return value["nip05"]; }
        set(s) { value["nip05"] = s }
    }
    
    var lightning_uri: URL? {
        return make_ln_url(self.lnurl)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode([String: String].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    static func displayName(profile: Profile?, pubkey: String) -> String {
        let pk = bech32_nopre_pubkey(pubkey) ?? pubkey
        return profile?.name ?? abbrev_pubkey(pk)
    }
}

func make_test_profile() -> Profile {
    return Profile(name: "jb55", display_name: "Will", about: "Its a me", picture: "https://cdn.jb55.com/img/red-me.jpg", banner: "https://pbs.twimg.com/profile_banners/9918032/1531711830/600x200",  website: "jb55.com", lud06: "jb55@jb55.com", lud16: nil, nip05: "jb55@jb55.com")
}

func make_ln_url(_ str: String?) -> URL? {
    return str.flatMap { URL(string: "lightning:" + $0) }
}

struct NostrSubscription {
    let sub_id: String
    let filter: NostrFilter
}

func lnaddress_to_lnurl(_ lnaddr: String) -> String? {
    let parts = lnaddr.split(separator: "@")
    guard parts.count == 2 else {
        return nil
    }
    
    let url = "https://\(parts[1])/.well-known/lnurlp/\(parts[0])";
    guard let dat = url.data(using: .utf8) else {
        return nil
    }
    
    return bech32_encode(hrp: "lnurl", Array(dat))
}
