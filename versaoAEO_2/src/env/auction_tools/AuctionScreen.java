// CArtAgO artifact code for project versaoAE
package auction_tools;

import cartago.*;

public class AuctionScreen extends Artifact {
	void init() {
		defineObsProperty("screenStatus", "closed");
	}

	@OPERATION
	void setStatus(String G) {
		ObsProperty g = getObsProperty("screenStatus");
		g.updateValue(G);
	}
}

