//
//  EventDetailsView.swift
//  EventExplorer
//
//  Created by vishnu vijayan on 2026-07-15.
//
import SwiftUI
import MapKit

struct EventDetailsView: View {

    let event: Event
    let onBookmark: (Event) -> Void

    var body: some View {
        List {
            Section {
                ImageCellView(imageUrl: event.imageUrl)
                TitleCellView(title: event.title, subtitle: event.time.formatted(.dateTime))
            }
            .listRowSeparator(.hidden)

            Section(header: Text("Location")) {
                LocationDetails(location: event.location)
                LocationMap(location: event.location)
                Button {
                    openInMaps(location: event.location)
                } label: {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
            }
            .listRowSeparator(.hidden)

        }
        .navigationTitle(event.title)
        .toolbar {
            Button {
                onBookmark(event)
            } label: {
                Image(systemName: event.isBookMarked ? "bookmark.fill" : "bookmark")
            }
        }

    }

    func openInMaps(location: Location) {
        let destinationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        destinationItem.name = location.name
        let currentLocationItem = MKMapItem.forCurrentLocation()
        MKMapItem.openMaps(
            with: [currentLocationItem, destinationItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
    }
}

// MARK: - Title cell
private struct TitleCellView: View {

    var title: String
    var subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
            Text(subtitle)
                .font(.subheadline.bold())
                .foregroundStyle(.gray)
        }
    }
}

// MARK: - Image cell view
private struct ImageCellView: View {

    var imageUrl: URL
    
    var body: some View {
        VStack(alignment: .leading) {
            CachedImageView(imageURL: imageUrl)
                .frame(height: 200)
                .frame(maxWidth: .infinity)

        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Location Details
private struct LocationDetails: View {
    @Environment(LocationManager.self) var locationService
    var location: Location
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text(location.name)
            Text(location.address)
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
            Text(locationService.distance(to: location.clLocation)?.formattedDistance ?? "")
        }
    }
}

// MARK: - Location cell view
private struct LocationMap: View {
    let location: Location

    var body: some View {
        Map {
            Marker(location.address, coordinate: .init(latitude: location.latitude, longitude: location.longitude))
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .disabled(true)
    }
}

#Preview {
    NavigationStack {
        EventDetailsView(event: Event(
            id: "1",
            title: "Toronto Jazz Night",
            time: Date(),
            imageUrl: URL(string: "https://picsum.photos/id/101/600/400")!,
            location: .init(
                name: "Rex Hotel Jazz Bar",
                address: "194 Queen St W, Toronto, ON",
                latitude: 43.6511,
                longitude: -79.3877
            )
        ), onBookmark: {_ in}
        )
        .environment(LocationManager())
    }

}
