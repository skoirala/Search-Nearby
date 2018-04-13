//
//  MapViewPresenter.swift
//  Search Nearby
//
//  Created by Sandeep Koirala on 13/04/2018.
//  Copyright © 2018 Sandeep Koirala. All rights reserved.
//

import Foundation

class MapViewPresenter: MapViewPresenterType {

    let router: Router
    let venue: Venue

    init(router: Router,
         venue: Venue) {
        self.router = router
        self.venue = venue
    }

    weak var view: MapViewType!

    func attach(view: MapViewType) {
        self.view = view
    }

    func viewAppeared() {
        let detail = MapViewDetailData(title: venue.name,
                                       subtitle: venue.address.formatted,
                                       latitude: Double(venue.address.latitude),
                                       longitude: Double(venue.address.longitude),
                                       imageUrl: venue.category?.thumbnailUrl)
        view.set(detail: detail)
    }

    func showVenueDetail() {
        router.showDetailView(venue: venue)
    }
}
