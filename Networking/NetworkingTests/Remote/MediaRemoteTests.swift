import XCTest
@testable import Networking

final class MediaRemoteTests: XCTestCase {
    /// Dummy Network Wrapper
    ///
    let network = MockupNetwork()

    /// Dummy Site ID
    ///
    let sampleSiteID: Int64 = 1234

    /// Dummy Product ID
    ///
    let sampleProductID: Int64 = 282

    /// Repeat always!
    ///
    override func setUp() {
        network.removeAllSimulatedResponses()
    }

    // MARK: - uploadMedia

    /// Verifies that `uploadMedia` properly parses the `products-load-all` sample response.
    ///
    func testLoadAllProductsProperlyReturnsParsedProducts() {
        let remote = ProductsRemote(network: network)
        let expectation = self.expectation(description: "Load All Products")

        network.simulateResponse(requestUrlSuffix: "products", filename: "products-load-all")

        remote.loadAllProducts(for: sampleSiteID) { products, error in
            XCTAssertNil(error)
            XCTAssertNotNil(products)
            XCTAssertEqual(products?.count, 10)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

}
