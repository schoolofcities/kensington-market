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
	import { createFootnoteStore } from "$lib/footnoteUtils";
	const footnoteStore = createFootnoteStore();
	const { footnotes, addFootnote } = footnoteStore;
	const fns = [
		"Statistic from 8 “City of Toronto Planning Board, Official Plan Proposal Study for Kensington Market, May 1978, pg. 37.” Quoted in 2024 KM HCD",
		"O'Neil, L. (2018). Here's what's replacing Casa Coffee in Kensington Market. BlogTO. <a href='https://www.blogto.com/eat_drink/2018/06/heres-whats-replacing-casa-coffee-kensington-market/' target='_blank'>https://www.blogto.com/eat_drink/2018/06/heres-whats-replacing-casa-coffee-kensington-market/</a><br/><br/>Knight, P. (2025). Toronto's Kensington Market losing yet another longtime independent business. BlogTO. <a href='https://www.blogto.com/eat_drink/2025/06/hooked-kensington-toronto-closing/' target='_blank'>https://www.blogto.com/eat_drink/2025/06/hooked-kensington-toronto-closing/</a><br/><br/>Neufeld, Abby. (2021) Kensington Market Is In Crisis After Over 20 Shops Have Had To Shut Their Doors Forever. Narcity. <a href='https://www.narcity.com/toronto/kensington-market-is-in-crisis-after-over-20-shops-have-had-to-shut-their-doors-forever' target='_blank'>https://www.narcity.com/toronto/kensington-market-is-in-crisis-after-over-20-shops-have-had-to-shut-their-doors-forever</a><br/><br/>Rebelo, Katherine. (2017). Oxford Fruit closing after almost 40 years in business. TasteToronto. <a href='https://www.tastetoronto.com/stories/oxford-fruit-closing' target='_blank'>https://www.tastetoronto.com/stories/oxford-fruit-closing</a>",
		"<a href='https://torontolife.com/food/the-sad-truth-is-that-kensington-market-isnt-healthy-anymore-why-this-neighbourhood-fishmonger-is-closing-up-shop/' target='_blank'>“The sad truth is that Kensington Market isn’t healthy anymore”: Why this neighbourhood fishmonger is closing up shop</a>  June 2, 2025, accessed 20 February 2026.",
		"Toronto Official Plan Office Consolidation - March 2022, Chapter 4: Land Use Designations <a href='https://www.toronto.ca/wp-content/uploads/2017/11/97dd-cp-official-plan-chapter-4.pdf' target='_blank'>https://www.toronto.ca/wp-content/uploads/2017/11/97dd-cp-official-plan-chapter-4.pdf</a>",
		"Cochrane, Jean. 2000. Kensington. Boston Free Press, 72. Cochrane’s book is an excellent source on Kensington history. ",
		"Jay Pitter, Preliminary Report: Research, Mapping & Engagement Little Jamaica Cultural District Planning Process <a href='https://www.toronto.ca/wp-content/uploads/2023/03/96e8-city-planning-little-jamaica-cultural-district-plan-preliminary-report.pdf' target='_blank'>https://www.toronto.ca/wp-content/uploads/2023/03/96e8-city-planning-little-jamaica-cultural-district-plan-preliminary-report.pdf</a>, quoted in KMCLT 2025: 13 ",
		"Sidewalks to Skylines: A Ten Year Economic Plan for Toronto, 2025-2035, p. 5.",
		"Russell, Dominique. 2025. KMCLT As Place Keeper: Kensington Market, Small Business, Community and the Challenges of Affordability. Toronto: KMCLT. P. 12. Accessed: <a href='https://files.cargocollective.com/c1710587/KMCLT-As-Place-Keeper-Report-2025.pdf' target='_blank'>https://files.cargocollective.com/c1710587/KMCLT-As-Place-Keeper-Report-2025.pdf</a>",
		"<a href='https://toronto.citynews.ca/video/2026/02/20/long-time-kensington-market-staple-setting-its-doors-after-35-years/' target='_blank'>https://toronto.citynews.ca/video/2026/02/20/long-time-kensington-market-staple-setting-its-doors-after-35-years/</a>",
		"<a href='https://www.blogto.com/eat_drink/2026/02/jumbo-empanadas-toronto-closed/' target='_blank'>https://www.blogto.com/eat_drink/2026/02/jumbo-empanadas-toronto-closed/</a>",
		"For this study, we consider Kensington Market’s borders as the south side of College Street, the east side of Bathurst, the north side of Dundas, and the west side of Spadina. See map below.",
		"Data Axle, 2022, Canadian historical business data, <a href='https://doi.org/10.5683/SP3/IPKREG' target='_blank'>https://doi.org/10.5683/SP3/IPKREG</a>, Borealis, V8, UNF:6:4y7XObkF3X9gFP+CysA9yg== [fileUNF]. Accessed 19 February 2026.",
		"We chose to use a solid line to represent the relationship between European Quality Meats and Sausages and its replacement Sanagan’s Meat Locker while different businesses with different owners, both are butchers. ",
		"Mannie, Kathryn. Locals celebrate new produce store in Kensington Market focused on affordability. TorontoToday.ca, Jan 10, 2026. <a href='https://www.torontotoday.ca/local/business-economy/kensington-market-new-produce-store-affordability-11723371' target='_blank'>https://www.torontotoday.ca/local/business-economy/kensington-market-new-produce-store-affordability-11723371</a>, accessed February 25, 2026.",
		"Kensington Market Heritage Conservation District Study. 2017. <a href='https://www.toronto.ca/legdocs/mmis/2017/pb/bgrd/backgroundfile-107024.pdf' target='_blank'>https://www.toronto.ca/legdocs/mmis/2017/pb/bgrd/backgroundfile-107024.pdf</a>, p. 31",
	];

	const credits = [
		{
			role: "Research and writing",
			people: [
				{ name: "Dr. Farzaneh Hemmasi", url: "https://music.utoronto.ca/person/farzaneh-hemmasi" },
				{ name: "Dr. Emily Hertzman", url: "https://www.linkedin.com/in/emily-hertzman-8b312b88/" },
			],
		},
		{
			role: "Data visualization",
			people: [
				{ name: "Scott McCallum", url: "https://www.linkedin.com/in/scott-christian-mccallum/" },
			],
		},
	];

	const projectDescription =
		"This project is the first output of Hemmasi's research project \"Keeping Kensington Market's Cultural Spaces\", funded by a <a href='https://schoolofcities.utoronto.ca/opportunities/urban-challenge-grant/urban-challenge-grants-4/' target='_blank'>2025-26 School of Cities Urban Challenge Grant</a> on the theme of inequality, data, and democracy. <br><br>This project is a collaboration with the <a href='https://kmclt.ca/' target='_blank'>Kensington Market Community Land Trust (KMCLT)</a>, a community initiative created to protect Kensington Market's social and economic diversity by collectively purchasing properties for affordable housing, the maintenance of historical eclectic mixed-use neighbourhood profile, and the sustenance of socio-economically and culturally diverse residents and businesses. <br><br>Our project supports the KMCLT's initiative to collect and publicly share land and property use data within Kensington Market to help the organization expand their mission of \"place-keeping.\"";
</script>

<main>
	<TitleVideo
		title="Charting Commercial Change in Kensington Market"
		subtitle=""
		video="./km-video-2023.mp4"
		videoOpacity="0.9"
		videoSpeed="0.5"
		titleFontColour="white"
		logoType="White"
	/>

	<div class="text">
		<div
			class="caption-container"
			style="margin-top: -62px; margin-bottom: 70px; padding-left: 0px; opacity: 0.6;"
		>
			<p>
				<span class="caption-text"
					><span class="caption-source"
						>Video source: <a
							href="https://www.youtube.com/watch?v=AgOryaSbzkg"
							target="_blank"
							>KMCLT Docuseries (School of Cities, 2023)</a
						></span
					></span
				>
			</p>
		</div>

		<AuthorDate
			{credits}
			date="April 2026"
			description={projectDescription}
		/>

		<p>
			What kind of market is today’s Kensington Market? What kind of
			market do Kensington Market community members want it to be? And how
			can data on neighbourhood change support Kensington
			Market’s communities’ desires to determine their collective future?
		</p>
		<p>
			In this article we trace the changing commercial landscape of the
			market by enumerating the decrease of green grocers and primary
			produce vendors and the increase in cannabis dispensaries and other
			types of retail business. This visualized and mapped quantitative
			data provides a snapshot of the ever-changing Kensington Market and
			raises questions about how the commercial profile of a neighbourhood
			is both a reflection of and a contributing factor to its livability,
			affordability, place-making, and place-keeping.
		</p>

		<p>
			In light of the accelerated change happening in the Market, our
			research team decided to generate data to quantify it. We believe in
			data as a tool for understanding the scale of these changes and
			advocating for policy or bylaw amendments that promote affordability
			and diversity within the commercial landscape of the market. With
			this data, KMCLT and other community groups can be better equipped
			to answer both the question of what kind of market they currently
			have, and what kind of market they would like it to be.
		</p>
	</div>

	<ImageSingle
		imageURL="./archives_km_6.jpg"
		altText=""
		maxWidth="1180px"
		link="Yes"
		caption="Toronto fire insurance plan in 1889."
		source="University of Toronto Map and Data Library."
	/>

	<div class="text">
		<h2>Constant Change in Kensington Market</h2>
		<p>
			The Kensington Market of the mid-twentieth century was full of fruit
			and vegetable stands, butchers, bakeries, and dry goods
			stores. Images from the past vividly illustrate how each wave of
			immigrants established shops in the neighbourhood, catering to the
			food staples and tastes of their respective cultures, whether
			Jewish, Portuguese, Latin American, Jamaican, Chinese, and more.
			Elderly former residents and shoppers remember when Kensington
			Market was the kind of market with live chickens in cages on the
			sidewalk, which were slaughtered and defeathered on the street or in
			an alley (such as at Augusta Kosher Poultry and Meat Market at 253
			Augusta Ave.); where bagels were sold on wooden rod by itinerate
			Jewish bakers, and where one could find tropical fruits like those
			sold by Toronto’s first banana importer (<a
				href="https://kmhs.ca/footnotes/2013/02/14/sancis-tropical-fruits/"
				target="_blank">Sanci’s Tropical Fruits</a
			>) at 66 Kensington Ave.
		</p>
		<ImageSingle
			imageURL="./archives_km_3.jpg"
			altText=""
			maxWidth="1180px"
			link="Yes"
			caption="Kensington Market, 1939-1951."
			source="Ronny Jaques, 1910-2008."
		/>
	</div>

	<div class="text">
		<p>
			Visiting Kensington Market today is a different, if no less
			stimulating an experience.  A tour of the central Market streets in
			2026 shows more restaurants, cafés, specialty stores, and cannabis
			retailers than green grocers and butchers. From one perspective,
			this is nothing new or noteworthy. As long ago as 1978, the City of
			Toronto Planning Study for Kensingtonii notes a “decline of grocery
			and food sellers as an overall proportion of businesses within the
			Market…from 67% in 1964 to 39% by 1977.”<Footnote
				id={addFootnote(fns[0])}
			/> Surveying historical photographs of the neighborhoodneighbourhood
			confirms that this decline of grocers has continued.
		</p>
	</div>

	<GraphicSingle
		svg1080="./archive-photos-1080.svg"
		svg720="./archive-photos-720.svg"
		svg360="./archive-photos-360.svg"
	/>
	<div class="text">
		<div
			class="caption-container"
			style="margin-top: -15px; margin-bottom: 50px;"
		>
			<p>
				<span class="caption-text"
					>Street scenes in Kensington Market in the 1970s by Ellis
					Wiley.
				</span>
				<span class="caption-source"
					>Source: City of Toronto Archives, Fond 124.</span
				>
			</p>
		</div>
	</div>

	<div class="text">
		<p>
			Change is a constant in urban centres, and Kensington is no
			different. But this particular change has met with strong reactions
			from inside and outside the neighbourhood’s boundaries. The decline
			of Kensington Market’s legacy businesses and food sellers is a
			recurring theme in local Toronto reporting, with scores of articles
			on this topic over the past decades.<Footnote
				id={addFootnote(fns[1])}
			/> The reasons cited for the change are diverse, from unaffordable commercial
			rents, changing patterns of immigrant entrepreneurship, and a different
			visitor profile with changing interests in goods and experiences.
		</p>
		<p>
			A recent Toronto Life article quoted Kristin Donovan, the owner of
			Hooked seafood stores, who closed her Kensington Market storefront
			at 206 Baldwin St. in the summer of 2025. When she moved into the
			neighbourhood in 2012, Donovan felt optimistic about the Market as a
			food destination and confident in her business prospects, but she
			describes a neighbourhood transformed:
		</p>
		<p class="quote">
			The tone of the market has changed. It seems to be mostly tourists
			and teenagers now, rather than the regular customers we had all
			grown used to. The neighbourhood is still cool and trendy, to be
			sure, and the energy is still great. But now people are just coming
			to walk around with a coffee instead of doing their groceries.
			They’re not looking to tote around a bag of fish. […] Recently, a
			lot of storefronts are up for rent, and the businesses that move in
			are hardly meeting the needs of the community: tattoo parlours, weed
			stores, mushroom dispensaries and restaurants that barely last a
			year.<Footnote id={addFootnote(fns[2])} />
		</p>
		<p>
			Donovan’s reference to commercial offerings in relation to “the
			needs of the community” is an important reminder that Kensington
			Market is and always has been more than a shopping district.
		</p>
		<p>
			Since its beginnings, Kensington Market has been a residential
			neighbourhood – its residents currently numbering around 3,500
			– whose occupants are among its stores’ primary customers. The
			historic combination of affordable rent and the availability
			of daily necessities close at hand is what attracted many current
			residents to move to the area.
		</p>

		<ImageSingle
			imageURL="./archives_km_7.jpg"
			altText=""
			maxWidth="1180px"
			link="Yes"
			caption="Augusta Ave. and Baldwin St. 1932."
			source="City of Toronto Archives."
		/>

		<p>
			Business and residential spaces are also physically intertwined.
			Especially on Kensington Ave., one finds many small
			businesses occupying the first floor of Victorian homes, a legacy of
			the neighbourhood’s historical pattern of setting up informal stores
			in street-level residences. Kensington Market is an unplanned,
			organically occurring mixed-use area “combining a broad array of
			residential uses, offices, retail and services, institutions,
			entertainment, recreation and cultural activities” within walkable
			distance – precisely the kind of urban land use the City of Toronto
			plans to invest in creating more of.<Footnote
				id={addFootnote(fns[3])}
			/>
		</p>

		<h2>More than goods and services</h2>
		<p>
			Kensington’s businesses offer their patrons much more than
			commodities and services. Over the years, its many community-serving
			businesses have simultaneously served as important sites of
			socializing, belonging, and care.
		</p>

		<ImageSingle
			imageURL="./archives_km_5.jpg"
			altText=""
			maxWidth="1180px"
			link="Yes"
			caption="Tivoli Billiards 1960s."
			source="Avard Woolaver."
		/>

		<p>
			In the 1960s, Portuguese men seeking work would make their way to
			Tivoli Billiards Hall (264 Augusta Ave.) and Brazil Restaurant (61
			Bellevue Ave.) places that were once “informal hiring halls.”<Footnote
				id={addFootnote(fns[4])}
			/>
			For nearly 50 years, Caribbean people in Toronto could find groceries
			and community at shop owner Yvonne Grant’s Caribbean Corner, still located
			at 171 Baldwin Ave. At 307 Augusta Ave., the café Pamenar has become
			one of the main gathering places for first-generation Iranian immigrants
			in the downtown core. The Portuguese bookstore at 86 Nassau St. was another
			important social meeting place. In Canadian popular culture, the CBC
			series <i>King of Kensington</i> was precisely about the social function
			of small immigrant stores: show protagonist Larry King was a variety
			store owner whose Kensington shop was one of several small business settings
			where locals found aid, information, and friendly conversation.
		</p>
	</div>

	<ImageSingle
		imageURL="./drum-map.png"
		altText="Alt text"
		maxWidth="1180px"
		link="Yes"
		caption="Map of businesses in Kensington Market from the 1980s."
		source="Kensington Market DRUM, December/January, 1989,1990."
	/>
	<div class="text">
		<p>
			The City of Toronto has prioritized small businesses in its <a
				href="https://www.toronto.ca/city-government/accountability-operations-customer-service/long-term-vision-plans-and-strategies/action-plan-toronto-economy/"
				target="_blank">recent economic strategy</a
			>. Pandemic-era public health measures disproportionately affected
			small businesses, spurring targeted programs like
			<a
				href="https://www.toronto.ca/business-economy/business-operation-growth/business-support/main-street-recovery-rebuild-initiative/"
				target="_blank">Mainstreet Recovery and Rebuilding Initiative</a
			> meant to help vulnerable businesses bounce back from this unprecedented
			challenge.
		</p>
		<p>
			Writing of small businesses and their cultural and
			social contributions in Toronto’s Little Jamaica
			neighbourhood, urbanist (and Kensington Market resident) Jay
			Pitter states:
		</p>
		<p class="quote">
			Local businesses—especially those tethered to racialized and
			newcomer communities—often bolster the economy, providing essential
			services such as the community provision of culturally desired foods
			and services. Also, many of these businesses serve as community hubs
			that provide informal mental health support, opportunities for
			intergenerational exchanges, safe(r) gathering spaces for youth, and
			compassionate mutual aid exchanges.<Footnote
				id={addFootnote(fns[5])}
			/>
		</p>

		<p>
			Finally, the 2025-2035 City of Toronto Economic Plan presents the
			City’s intention to implement commercial rent control, small
			business tax relief, and other measures meant to “[ensure] Toronto’s
			unique small business districts are vital anchors for community
			activity, from commerce to civic engagement.”<Footnote
				id={addFootnote(fns[6])}
			/> The document lists Kensington Market as one of the small business
			districts the City’s measures are intended to protect.
		</p>
		<p>
			The KMCLT has identified community-serving local businesses as a
			priority area of research and advocacy. The organization’s original
			focus on residential affordability has extended to an interest in
			tracking how increasingly unaffordable commercial rents have changed
			the neighbourhood’s business make-up. As Kensington has become a
			less affordable place to live, it has also become a more expensive
			place to operate a business. The organization articulates this
			perspective in its <a
				href="https://kmclt.ca/Reports"
				target="_blank">2025 report on “place-keeping”</a
			>:
		</p>
		<p class="quote">
			When KMCLT emerged ten years ago, there was concern that rising
			commercial rents were making it impossible to sell raw foods, that
			the rents could only be afforded by bars and restaurants, and
			that Kensington would become a destination for tourists and
			Torontonians, but not for its residents, who are largely renters and
			lower income than the rest of the city. …An unfortunate consequence
			of this polarization of incomes and gentrification is a
			widening separation between the commercial and residential, in which
			the commercial no longer serves residents’ needs.<Footnote
				id={addFootnote(fns[7])}
			/>
		</p>
		<p>
			Local independent businesses are often more vulnerable than their
			larger franchise competitors. While the pandemic
			period put exceptional stress on small businesses, the exponentially
			rising retail rents and building sales that preceded the pandemic
			and continue today are one of the most pressing challenges. For
			legacy businesses, second and third generations may not be
			interested in or able to continue the family trade. Changing
			patterns of entrepreneurship and immigration are all likely
			contributors.
		</p>

		<ImageSingle
			imageURL="./kensington_EL.jpg"
			altText=""
			maxWidth="1180px"
			link="Yes"
			caption="Shop houses on Kensington Ave."
			source="Emily Hertzman."
		/>

		<p>In other cases, small business owners simply want a change.</p>
		<p>
			In February 2026, Irene Morales, whose business Jumbo Empanadas
			opened in 1987, announced she was closing her shop. Although she
			owns the building in which her store is located, she cites rising
			costs, thinner margins, fewer customers since the pandemic, and her
			own aging as reasons for closing. In an interview with Toronto City
			News, Morales related that longtime patrons had begged her to stay
			open, but despite her feelings of guilt and the knowledge that her
			store would be missed, she chose not to continue.<Footnote
				id={addFootnote(fns[8])}
			/> She is now renting out her store. "I decided…I'm going to rent it
			out, because I'm getting sick, emotionally, mentally, physically, because
			of the stress. The stresses start to affect you.”<Footnote
				id={addFootnote(fns[9])}
			/>
		</p>

		<h2>Tracking shifts in businesses in Kensington Market</h2>

		<p>
			We compiled data from a variety of sources to verify and understand
			the scale of business type change in Kensington Market over time.<Footnote
				id={addFootnote(fns[10])}
			/> In July and August of 2025, we confirmed the presence of current businesses by
			walking through the Market, verifying and updating online data, and talking
			to market shop owners and residents. We then compiled historical business data
			from a series of older sources, including data collected by volunteers
			from the KMCLT and by members of the Kensington Market Historical Society.
			This was supplemented with Data Axle’s Canadian Historical Business Data
			(2009-2022), a large dataset that we refined and cross-checked against
			our other sources.<Footnote id={addFootnote(fns[11])} />
		</p>
		<p>
			We then developed a categorization system for present and past
			businesses and organizations according to types of goods and
			services found in Kensington Market:
		</p>

		<ul>
			<li>
				<span class="highlight" style="background-color: #46c0b5;"
					>Arts and performance:</span
				> art galleries, studios, performance spaces, cinemas, recording
				studios
			</li>
			<li>
				<span class="highlight" style="background-color: #5ac7da;"
					>Medical:</span
				> medical facilities, doctors' and dentists' offices, clinics, Toronto
				Western Hospital
			</li>
			<li>
				<span class="highlight" style="background-color: #82a0d3;"
					>Services:</span
				> salons, tattoo parlors, car rentals and mechanics, laundromats,
				plumbers, banks
			</li>
			<li>
				<span class="highlight" style="background-color: #e1c542;"
					>Social / community:</span
				> houses of worship, non-profit social service organizations, community
				organizations and associations, schools and educational institutions
			</li>
			<li>
				<span class="highlight" style="background-color: #1b8079;"
					>Foodstuffs:</span
				> sellers of raw and dry goods, cheese shops, butchers, bakeries,
				fish sellers, spices, health food stores
			</li>
			<li>
				<span class="highlight" style="background-color: #6459a7;"
					>Retail:</span
				> specialty stores, boutiques, vintage clothing stores, cannabis,
				mushrooms and vapes
			</li>
			<li>
				<span class="highlight" style="background-color: #e64c3c;"
					>Restaurants and bars:</span
				> eat-in and take-out cafes restaurants and bars
			</li>
		</ul>

		<p>
			Using this data, we chart the non-residential compositional makeup
			of Kensington Market. This shows a substantial increase in the
			proportion of restaurants and bars (from 21.3% in 2009 to 32.7% in
			2025), a small increase in retail (from 27.6% in 2009 to 29.5% in
			2025), and a marginal increase in arts and performance spaces
			(+1.3%). Declines are seen in medical services (9.3% in 2009 to 6.3%
			in 2025) and – most strikingly - the social/community and foodstuffs
			categories. Social and community land use in the Market decreased by
			44% - from 8.7% in 2009 to 4.9% in 2025. Foodstuffs sellers showed
			the greater overall decrease, from 57 businesses (13.3%) in 2009 to
			just 26 (6.3%) in 2025 – a 53% decrease in 14 years. This is a
			considerable change from the historical concentrations of butchers,
			bakers, dairies, and primary produce vendors, located in the heart
			of the Market, and surrounded by schools, churches, synagogues,
			social clubs, and social service centres.
		</p>
	</div>

	<GraphicSingle
		svg720="./km-bar-time-series-720.svg"
		svg360="./km-bar-time-series-360.svg"
	/>

	<div class="text">
		<p>
			A closer look at the 2025 data reveals that Kensington’s
			non-residential activity remains eclectic.
		</p>
		<p>
			Of 410 locations surveyed, we found 121 retail locations, 134 bars
			and restaurants, 15 arts and performance venues, 26 medical service
			centers, 26 primary food sellers, 68 other types of service
			businesses, and 20 community organizations within its boundaries.
		</p>

		<ImageSingle
			imageURL="./nested-donut.png"
			altText="Nested donut chart of business types in Kensingtone Market, 2025"
			maxWidth="1180px"
			link="Yes"
			caption=""
			source=""
		/>

		<p>
			Food remains central to the Market’s commercial profile, but in 2025
			it was prepared foods that were most plentiful. The number of
			dine-in and take-out restaurants, bars, and cafés accounts for 32.7%
			of commercial activity or 134 businesses. Put together, foodstuffs
			and restaurant/bars make up 39% of Kensington’s businesses.
		</p>
		<p>
			Kensington Market’s retailers are diverse and numerous (121 or
			29.5%), percentagewise nearly on par with the restaurants and bars
			(134 or 32.7%). The retail category includes a sizeable number of
			specialty stores (56) and vintage clothing stores (24). In 2025,
			<a
				href="https://kmhs.ca/footnotes/zimmerman-tribute/"
				target="_blank"
				>discount stores, which were historically part of Kensington’s
				commercial identity</a
			>, make up just 12.4% of retail. The businesses identified as
			offering services, including 14 salons and 7 tattoo parlors, add to
			the commercial diversity and contribute significantly to the Market
			as a pedestrian destination.
		</p>
		<p>
			Stores selling cannabis, mushrooms, and vapes collectively represent
			nearly 11% of all retail in Kensington Market and 3% of the
			neighbourhood’s overall non-residential activity. While cannabis
			legalization has played a role in this sector’s growth, the history
			of cannabis retailing in the Market precedes its 2018 legalization
			by several decades. Toronto’s very first cannabis consumption lounge
			<a
				href="https://torontolife.com/city/i-ran-hotbox-torontos-first-cannabis-consumption-lounge-for-20-years-now-its-closing/"
				target="_blank">HotBox</a
			> (originally called Roach-o-Rama) opened in Kensington in 2000 and closed
			in 2022. As of 2025, there are 8 cannabis retailers in the neighbourhood.
		</p>
		<p>
			The historic combination of affordable rent and the availability
			of daily necessities close at hand is what attracted many current
			residents to move to the neighbourhood.
		</p>

		<h2>What happened to the grocery stores?</h2>
		<br />

		<ImageSingle
			imageURL="./archives_km_4.jpg"
			altText=""
			maxWidth="1180px"
			link="Yes"
			caption="Nassau St. and Augusta Ave. in Kensington Market in 1966."
			source="Toronto Star."
		/>
		<p>
			Using a combination of KMCLT data and Google Maps Street View from
			2007, we identified the names and addresses of all 31 grocers. We
			then compared this historical data with the businesses occupying
			those same addresses in 2025, representing continuity between past
			and present businesses with a solid line, and change with a dotted
			line.<Footnote id={addFootnote(fns[12])} /> Our data shows that only
			11 of the 31 grocers remain open in 2025.
		</p>
	</div>

	<GraphicSingle
		svg1080="./km-sankey-1080.svg"
		svg720="./km-sankey-720.svg"
		svg360="./km-sankey-360.svg"
	/>

	<div class="text">
		<h3>Mapping the disappearance of grocers since 2007</h3>
		<p>
			To convey the Market’s commercial dynamism, we created an
			interactive map and timeline showing the change of grocers into
			other types of businesses from 2007 to 2025. The map consolidates
			multiple data points into a single framework.
		</p>
		<p>
			You can download the data <a
				href="./kensingtonMarketBusinessChange2007to2025.geojson"
				target="_blank">here</a
			>.
		</p>
	</div>

	<TimelineVisualization
		bind:sliderYear
		bind:hoveredAddress
		bind:yearlyTypeCounts
		bind:enabledTypes
	/>

	<div class="text">
		<p>
			To use the map, hold the curser over a coloured dot to see the
			changes in type of business over time at a specific location. Slide
			the timeline using the arrow to see the dots change colour
			indicating changes in the categorization of businesses over time. In
			the data summary at the top, are the number of losses and gains in
			each business category since the 2007 snapshot. A pop-up window on
			each map point displays a timeline for businesses occupying the
			selected address.
		</p>
		<h2>Conclusion</h2>
		<p>
			Our data indicate a clear and ongoing transformation in Kensington
			Market. Fresh food vendors and green grocers are declining in
			number, while prepared food establishments, bars, restaurants, and
			retail outlets now make up the majority of businesses in the area.
			We also note the reduction in community and social serving
			organizations. This shift reflects broader urban pressures —
			escalating commercial rents, rising property values, increasing
			costs of doing business, intergenerational transfer of business,
			changing lifestyles and consumption habits, and more. Many of these
			challenges are also reshaping other Toronto neighbourhoods but are
			felt acutely by Kensington community members and observers alike.
		</p>
		<p>
			In tandem with its rich and well-known history, Kensington Market’s
			small-scale, affordable, and village-like atmosphere in the centre
			of Toronto makes changes to the area feel more pronounced than in
			other areas. KMCLT’s work advocating for residential affordability
			to prevent the eviction and displacement of long-term low incomes
			residents, is part of resisting these urban development pressures.
		</p>
		<p>
			However, there is an increasing awareness that commercial
			affordability is another key factor in keeping a neighbourhood
			liveable over a sustained time. Kensington Market has long had an
			identity as a market, a source of food for multiple and constantly
			evolving communities, not only for local residents, but for many
			groups of people scattered throughout the city to find specialty
			foods or less common cultural food items. That is changing now, as
			primary produce vendors shifts to prepared food.
		</p>
		<p>
			In the course of researching this blog post, a new grocer emerged:
			on New Year’s Eve of 2025, Ravi Ramoutar opened Kensington
			Vegetables and Flowers, a new produce shop at 274 Augusta Ave. The
			small shop has been eagerly welcomed by KMCLT’s Dominque Russell:
		</p>
		<p class="quote">
			“The truth of it is Kensington is not going to have four green
			grocers or fruit stands on the corner again because shopping habits
			have changed…[b]ut any raw food seller that comes into the Market is
			a real win because it's not a vape shop, it's not a marijuana shop —
			it's something that really serves the neighbourhood.<Footnote
				id={addFootnote(fns[13])}
			/>
		</p>
		<p>
			In 2025, the City of Toronto designated Kensington Market a Heritage
			Conservation district, preserving the built environment and
			recognizing that the Market’s “fine-grain commercial space has
			contributed to the concentration of independent businesses that
			support a sense of place and a uniquely animated public realm”.<Footnote
				id={addFootnote(fns[14])}
			/>
		</p>
		<p>
			In the economic realm, the City of Toronto’s February 2026
			announcement that it would
			<a
				href="https://www.toronto.ca/news/city-of-toronto-lowers-small-business-property-taxes-through-2026-budget/"
				target="_blank">lower small business property taxes</a
			>, and its stated intention to limit commercial rents by 2030,
			suggest the municipality’s willingness to take steps to lessen small
			businesses’ economic vulnerability.
		</p>
		<p>
			The City of Toronto’s attentiveness to small businesses, and
			specifically to Kensington Market, is encouraging. But it takes time
			for their effects to be implemented and more time still for their
			impacts to be felt on the ground. Meanwhile, The Kensington Market
			Community Land Trust will continue to track, support, and advocate
			for Kensington’s small business community. We look forward to
			supporting them in this important effort.
		</p>

		<br /><br />

		<Footnotes {footnotes} />

		<br /><br />
	</div>
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
