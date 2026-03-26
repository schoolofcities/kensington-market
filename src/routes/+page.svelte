<script>

	import TitleVideo from "$lib/TitleVideo.svelte";
	import GraphicSingle from "$lib/GraphicSingle.svelte";
	import AuthorDate from "$lib/AuthorDate.svelte";
	import ImageSingle from "$lib/ImageSingle.svelte";

	import TimelineVisualization from "$lib/TimelineVisualization.svelte";
	let sliderYear = 2025.5;
	let hoveredAddress = null; // Shared hover state
	let yearlyTypeCounts = {}; // Shared between Timeline and Legend
	let enabledTypes = {}; // Shared filter state

	import Footnote from "$lib/Footnote.svelte";
	import Footnotes from "$lib/Footnotes.svelte";
	import { createFootnoteStore } from '$lib/footnoteUtils';
	const footnoteStore = createFootnoteStore();
	const { footnotes, addFootnote } = footnoteStore;
	const fns = [
		'Statistic from 8 “City of Toronto Planning Board, Official Plan Proposal Study for Kensington Market, May 1978, pg. 37.” Quoted in 2024 KM HCD',
		'Second footnote ...'
	]

	const credits = [
		{ role:"Research and writing", names:"Farzaneh Hemmasi, Dr. Emily Hertzman"},
		{ role:"Data visualization", names:"Scott McCallum"}	
	]

</script>



<main>

	<TitleVideo
		title="Charting Commercial Change in Kensington Market"
		subtitle=""
		video="./km-video-2023.mp4"
		videoOpacity=0.9
		videoSpeed=0.5
		titleFontColour="white"
		logoType="White"
	/>

	

	<div class="text">

		<div class="caption-container" style="margin-top: -62px; margin-bottom: 70px; padding-left: 0px; opacity: 0.6;">
		<p>
			<span class="caption-text"><span class="caption-source">Video source: <a href="https://www.youtube.com/watch?v=AgOryaSbzkg" target="_blank">KMCLT Docuseries (School of Cities, 2023)</a></span></span>
		</p>
	</div>

		<AuthorDate 
			credits={credits} 
			date="April 2026"
		/>

		<p>
			What kind of market is today’s Kensington Market? What kind of market do Kensington Market community members want it to be? And how can data on neighborhood change support Kensington communities’ desires to determine their collective future?   
		</p>
		<h2>Constant Change in Kensington Market  </h2>
		<p>
			The Kensington Market of the mid-twentieth century was full of fruit and vegetable stands, butchers, bakeries, and dry goods stores. Images from the past vividly illustrate how each wave of immigrants established shops in the neighborhoodneighbourhood, catering to the food staples and tastes of their respective cultures, whether Jewish, Portuguese, Latin American, Jamaican, Chinese, and more. Elderly former residents and shoppers remember when Kensington was the kind of market with live chickens in cages on the sidewalk and have them slaughtered and defeathered on the street or in the alley (such as at Augusta Kosher Poultry and Meat Market at 253 Augusta), where bagels were sold on wooden rod by itinerate Jewish bakers, and where one could find tropical fruits like those sold by Toronto’s first banana importer (Sanci’s Tropical Fruits) at 66 Kensington Avenue.  
		</p>
		
	</div>

	<GraphicSingle
		svg1080="./archive-photos-1080.svg"
		svg720="./archive-photos-720.svg"
		svg360="./archive-photos-360.svg"
	/>

	

	<div class="text">
		<div class="caption-container" style="margin-top: -15px; margin-bottom: 50px;">
			<p>
				<span class="caption-text">Street scenes in Kensington Market in the 1970s by Ellis Wiley. </span> <span class="caption-source">Source: City of Toronto Archives, Fond 124.</span>
			</p>
		</div>
	</div>

	<div class="text">
		<p>
			Visiting Kensington Market today is a different -- if no less stimulating -- experience. A tour of the central Market streets in 2026 shows more restaurants, cafes, specialty stores, and cannabis retailers than green grocers and butchers. From one perspective, this is nothing new or noteworthy. As long ago as 1978, athe City of Toronto Planning Study for Kensington Market notes a “decline of grocery and food sellers as an overall proportion of businesses within the Market…from 67% in 1964 to 39% by 1977.”<Footnote id={addFootnote(fns[0])}/>  Surveying historical photographs of the neighborhoodneighbourhood confirms that this decline of grocers has continued.  
		</p>
	</div>

	<ImageSingle
		imageURL="./drum-map.png"
		altText="Alt text"
		maxWidth="1180px"
		link="Yes"
		caption="Map of businesses in Kensington Market from the 1980s"
		source="Source?"
	/>

	<div class="text">
		<p>
			Change is a constant in urban centers, and Kensington is no different. But this particular change has met with strong reactions from inside and outside the neighbourhood’s boundaries. The decline of Kensington Market’s legacy businesses and food sellers is a recurring theme in local Toronto reporting, with scores of articles on this topic over the past decades.iii The reasons cited for the change are diverse, from unaffordable commercial rents, changing patterns of immigrant entrepreneurship, a different profile of visitors coming to Kensington Market interested in different kinds of goods and experiences. 
		</p>
		<p>
			A Toronto Life article quotes Kristin Donovan, the owner of Hooked seafood stores, who closed her Kensington storefront at 206 Baldwin in the summer of 2025. When she moved into Kensington in 2012, Donovan felt optimistic about the Market as a food destination and confident in her business prospects. She describes a neighborhoodneighbourhood transformed:  
		</p>
		<p class="quote">
			The tone of the market has changed. It seems to be mostly tourists and teenagers now, rather than the regular customers we had all grown used to. The neighbourhood is still cool and trendy, to be sure, and the energy is still great. But now people are just coming to walk around with a coffee instead of doing their groceries. They’re not looking to tote around a bag of fish. […] Recently, a lot of storefronts are up for rent, and the businesses that move in are hardly meeting the needs of the community: tattoo parlours, weed stores, mushroom dispensaries and restaurants that barely last a year. iv  
		</p>
		<p>
			Kristin’s reference to commercial offerings in relation to “the needs of the community” is an important reminder that Kensington is and always has been more than a shopping district.  
		</p>

		<h2>Changing business landscapes</h2>

		<p>
			For this project, we have We compiled data from a variety of sources to verify and understand the scale of business type change in Kensington Market over time.xii  In July and August of 2025, we confirmed current businesses by walking through the Market, verifying and updating online data, and talking to market shop owners and residents. We then compiled historical business data from a series of older sources, including data collected by volunteers from the KMCLT and by members of the Kensington Market Historical Society. This was supplemented with Data Axle's Canadian Historical Business Data (2009-2022), a large dataset that we refined and cross-checked against our other sources.xiii 
		</p>

		<ul>
			<li><span class="highlight" style="background-color: #46c0b5;">Arts and performance:</span> art galleries, studios, performance spaces, cinemas, recording studios</li>
			<li><span class="highlight" style="background-color: #5ac7da;">Medical:</span> medical facilities, doctors' and dentists' offices, clinics, Toronto Western Hospital</li>
			<li><span class="highlight" style="background-color: #82a0d3;">Services:</span> salons, tattoo parlors, car rentals and mechanics, laundromats, plumbers, banks</li>
			<li><span class="highlight" style="background-color: #e1c542;">Social / community:</span> houses of worship, non-profit social service organizations, community organizations and associations, schools and educational institutions</li>
			<li><span class="highlight" style="background-color: #1b8079;">Foodstuffs:</span> sellers of raw and dry goods, cheese shops, butchers, bakeries, fish sellers, spices, health food stores</li>
			<li><span class="highlight" style="background-color: #6459a7;">Retail:</span> specialty stores, boutiques, vintage clothing stores, cannabis, mushrooms and vapes</li>
			<li><span class="highlight" style="background-color: #e64c3c;">Restaurants and bars:</span> eat-in and take-out cafes restaurants and bars</li>
		</ul>

		<p>
			Our first chart tracksUsing this data, we chart thethe compositional makeup of Kensington non-residential activities from 2009 to 2025. This shows a substantial increase in the proportion of restaurants and bars (from 21.3% in 2009 to 32.7% in 2025), a small increase in retail (from 27.6% in 2009 to 29.5% in 2025), and a marginal increase in arts and performance spaces (+1.3%). Declines are seen in medical services (9.3% in 2009 to 6.3% in 2025) and – most strikingly - the social/community and foodstuffs categories.  Social and community land use in Kensington decreased by 44% - from 8.7% in 2009 to 4.9% in 2025. Foodstuffs sellers showed the greater overall decrease, from 57 businesses (13.3%) in 2009 to just 26 (6.3%) in 2025 – a 53% decrease in 14 years. This is a considerable change from the historical concentrations of butchers, bakers, dairies, and primary produce vendors, located in the heart of the market, and surrounded by schools, churches, synagogues, social clubs, and social service centers.
		</p>
	</div>

	<GraphicSingle
		svg720="./km-bar-time-series-720.svg"
		svg360="./km-bar-time-series-360.svg"
	/>

	<div class="text">

		<p>
			A closer look at the 2025 data reveals that Kensington’s non-residential activity remains eclectic.
		</p>
		<p>
			Food remains central to Kensington’s commercial profile, but in 2025 it was prepared foods that were most plentiful. The number of dine-in and take-out restaurants, bars, and cafes accounts for 32.7% of commercial activity or 134 businesses. Put together, foodstuffs and restaurant/bars make up 39% of Kensington’s businesses.   
		</p>
		<p>
			Kensington’s retailers are diverse and numerous (121 or 29.5%), percentagewise nearly on par with the restaurants and bars (134 or 32.7%). The retail category includes a sizeable number of specialty stores (56) and vintage clothing stores (24). In 2025, discount stores, which were historically part of Kensington’s commercial identity, make up just 12.3% of retail.  The businesses identified as offering services, including 14 salons and 7 tattoo parlors, add to the commercial diversity and contribute significantly to the Market as a pedestrian destination.
		</p>

	</div>

	<GraphicSingle
		svg1080="./km-sankey-1080.svg"
		svg720="./km-sankey-720.svg"
		svg360="./km-sankey-360.svg"
	/>

	<div class="text">


	</div>

	<div class="text">

		<h3>
			Mapping the disappearance of grocers
			since 2007
		</h3>

	</div>

	
	<TimelineVisualization
		bind:sliderYear
		bind:hoveredAddress
		bind:yearlyTypeCounts
		bind:enabledTypes
	/>

	<br><br>

	<Footnotes footnotes={footnotes}/>

	<br><br>

</main>

<style>
	/* .section-title {
		font-size: 1.2rem;
		font-weight: 500;
		margin: 0rem auto 0rem auto;
		color: #222;
		letter-spacing: 0.01em;
		max-width: 800px;
		text-align: left;
	}
	:global(body) {
		margin: 0;
		font-family:
			"FavoritVariable",
			-apple-system,
			BlinkMacSystemFont,
			"Segoe UI",
			Roboto,
			sans-serif;
		line-height: 1.2;
		color: #5c5c5c;
		background-color: #ffffff;
	}

	main {
		padding: 0rem 2rem 4rem 2rem;
	}

	@media (max-width: 480px) {
		main {
			padding: 0rem 1rem 2rem 1rem;
		}
	}

	.text-content {
		max-width: 800px;
		margin: 0 auto;
	}

	h1,
	h2,
	h3,
	h4,
	h5,
	h6 {
		font-weight: normal;
	}

	h1 {
		margin-bottom: 0em;
		color: #222;
	}

	.authors {
		font-size: 0.8rem;
		line-height: 0.5;
	}

	.blog-text {
		font-size: 1.1rem;
		color: #2c2c2c;
		max-width: 800px;
		font-size: 20px;
	}

	.blog-text p {
		margin-bottom: 1.5rem;
	}

	.sankey {
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	.caption {
		font-size: 0.8rem;
		color: #979797;
		margin-top: 0.5rem;
		text-align: center;
	}

	.pie-charts {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
		gap: 0;
		margin: 0;
	}

	.pie-charts > div {
		display: flex;
		flex-direction: column;
		align-items: center;
		overflow: hidden;
	}

	.pie-charts img {
		height: 400px;
		width: auto;
		max-width: 100%;
	}

	@media (max-width: 600px) {
		.pie-charts {
			grid-template-columns: 1fr;
		}

		.pie-charts img {
			height: auto;
			width: 100%;
			max-width: 100%;
		}
	} */
</style>
