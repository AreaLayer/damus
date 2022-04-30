//
//  ProfileModel.swift
//  damus
//
//  Created by William Casarin on 2022-04-27.
//

import Foundation

class ProfileModel: ObservableObject {
    @Published var events: [NostrEvent] = []
    @Published var pubkey: String?
    var seen_event: Set<String> = Set()
    
    var sub_id = UUID().description
    
    var pool: RelayPool? = nil
    
    deinit {
        unsubscribe()
    }
    
    func unsubscribe() {
        print("unsubscribing from profile \(pubkey ?? "?") with sub_id \(sub_id)")
        pool?.unsubscribe(sub_id: sub_id)
    }
    
    func set_pubkey(_ pk: String) {
        if pk == self.pubkey {
            return
        }
        
        self.events.removeAll()
        self.seen_event.removeAll()
        
        unsubscribe()
        self.sub_id = UUID().description
        self.pubkey = pk
        subscribe()
    }
    
    func subscribe() {
        guard let pubkey = self.pubkey else {
            return
        }
        
        let kinds: [Int] = [
            NostrKind.text.rawValue,
            NostrKind.delete.rawValue,
            NostrKind.boost.rawValue
        ]
        
        var filter = NostrFilter.filter_kinds(kinds)
        filter.authors = [pubkey]

        print("subscribing to profile \(pubkey) with sub_id \(sub_id)")
        pool?.subscribe(sub_id: sub_id, filters: [filter], handler: handle_event)
    }
    
    func add_event(_ ev: NostrEvent) {
        if seen_event.contains(ev.id) {
            return
        }
        if ev.kind == 1 {
            self.events.append(ev)
            self.events = self.events.sorted { $0.created_at > $1.created_at }
        }
        seen_event.insert(ev.id)
    }
    
    private func handle_event(relay_id: String, ev: NostrConnectionEvent) {
        switch ev {
        case .ws_event:
            return
        case .nostr_event(let resp):
            switch resp {
            case .event(let sid, let ev):
                if sid != self.sub_id {
                    return
                }
                add_event(ev)
            case .notice(let notice):
                notify(.notice, notice)
            }
        }
    }
}
