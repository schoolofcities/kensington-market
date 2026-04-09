<script>
	import "../assets/styles.css"
	import LogoBlack from '../assets/sofc-uoft-logo-black.svg';
	import LogoWhite from '../assets/sofc-uoft-logo-white.svg';
	import LogoKMCLT from '../assets/kmclt-white.png';

	export let title = '';
	export let subtitle = '';
	export let titletype = '';
	export let video = '';          // <-- mp4 path
	export let videoOpacity = 1;
	export let videoSpeed = 1;      // <-- playback speed prop
	export let titleFontColour = 'var(--brandDarkBlue)';
	export let subtitleFontColour = 'var(--brandDarkBlue)';
	export let logoType = 'Black';

	let divWidth;
	let videoEl;

	let Logo;
	$: Logo = logoType === 'Black'
		? LogoBlack
		: logoType === 'White'
		? LogoWhite
		: '';

	// reactively update playback speed
	$: if (videoEl) {
		videoEl.playbackRate = videoSpeed;
	}
</script>


<div class="title-container" bind:clientWidth={divWidth}>

	<!-- Background Video -->
	{#if video}
		<video
			class="background-video"
			bind:this={videoEl}
			autoplay
			muted
			loop
			playsinline
			style="opacity: {videoOpacity};"
		>
			<source src={video} type="video/mp4" />
		</video>
	{/if}


	<div class="logo-container">
		{#if logoType !== 'None'}
			<a href="https://kmclt.ca/" target="_blank" class="logo-link">
				<img src={LogoKMCLT} alt="UofT and School of Cities logos" class="logo-top" />
			</a>
			<a href="https://schoolofcities.utoronto.ca/" target="_blank" class="logo-link">
				<img src={Logo} alt="UofT and School of Cities logos" class="logo-top" style="margin-bottom: 8px; margin-left: 8px;" />
			</a>
			
		{/if}
	</div>

	<div class="title-text-container">

		<h3 style="color: {titleFontColour};">
			{titletype}
		</h3>
		
		<h1 style="color: {titleFontColour};">{title}</h1>

		{#if divWidth > 600}
			<h2 style="color: {subtitleFontColour};">{subtitle}</h2>
		{/if}

	</div>

</div>


<div class="subtitle-text-container">
	{#if divWidth <= 600}
		<h2 style="color: black;">{subtitle}</h2>
	{/if}
</div>


<style>

	.title-container {
		height: 100dvh;
		width: 100%;
		background-color: rgb(0, 0, 0);
		position: relative;
		margin-bottom: 60px;
		overflow: hidden;
	}

	.background-video {
		position: absolute;
		width: 100%;
		height: 100%;
		object-fit: cover;
	}

	.logo-container {
		position: absolute;
		/* top: 75px; */
		bottom: 320px;
		left: 75px;
		z-index: 2;
	}

	.logo-link {
		filter: drop-shadow(0px 0px 8px rgba(0, 0, 0, 0.32))
	}

	.logo-link:hover {
		opacity: 0.8;
		filter: drop-shadow(0px 0px 8px rgba(0, 0, 0, 1))
	}

	.title-text-container {
		max-width: 720px;
		position: absolute;
		bottom: 125px;
		left: 75px;
		z-index: 2;
	}

	.title-text-container h1 {
		font-family: TradeGothicBold;
		font-weight: normal;
		font-size: 64px;
		margin-bottom: 10px;
		text-shadow: 0px 0px 20px rgba(0, 0, 0, 0.6); 
	}

	.title-text-container h2 {
		text-align: left;
		font-family: SourceSerif;
		font-weight: normal;
		font-size: 28px;
		margin-top: 0px;
		text-shadow: 0px 0px 10px rgba(0, 0, 0, 0.8); 
	}

	.title-text-container h1 {
		font-family: TradeGothicBold;
		font-weight: normal;
		font-size: 60px;
		margin-bottom: 10px;
		text-shadow: 0px 0px 20px rgba(0, 0, 0, 0.6); 
	}

	.subtitle-text-container {
		max-width: 600px;
		margin: 20px;
		margin-bottom: 40px;
	}

	.subtitle-text-container h2 {
		font-size: 22px;
		font-family: SourceSerifBold;
		font-weight: normal;
	}

	.logo-top {
		width: 255px;
		height: auto;
	}


	@media (max-width: 1000px) {
		.logo-top {
			width: 200px;
			height: auto;
		}

		.logo-container {
			left: 75px;
			bottom: 280px;
		}

		.title-text-container h1 {
			font-size: 48px;
		}
	}

	@media (max-width: 800px) {

		.logo-container {
			left: 75px;
			bottom: 300px;
		}
	}
	

	@media (max-width: 650px) {

		.title-container {
			height: 100dvh;
			margin-bottom: 5px;
		}

		.logo-container {
			left: 20px;
			bottom: 150px;
		}

		.logo-top {
			width: 150px;
			height: auto;
		}

		.title-text-container {
			left: 20px;
			bottom: 10px;
			padding-right: 10px;
		}

		.title-text-container h1 {
			font-size: 42px;
			line-height: 52px;
		}

		.title-text-container h2 {
			font-size: 24px;
		}
	}

	@media (max-width: 531px) {
		.logo-container {
			left: 20px;
			bottom: 200px;
		}

	}

	@media (max-width: 390px) {
		.logo-container {
			left: 20px;
			bottom: 250px;
		}

	}

</style>
