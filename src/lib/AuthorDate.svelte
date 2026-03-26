<script>

	import "../assets/styles.css";

	export let authors = "";
	export let graphics = ""
	export let research = "";
	export let writing = "";
	export let date = "";
	export let credits = [];

</script>


<div class="author-date">

	<p>
		{#if authors}
			By {@html authors}
		{/if}
		{#if research}
			<br>
			<span class="role">Research:</span> {@html research}
		{/if}
		{#if graphics}
			<br>
			<span class="role">Graphics:</span> {@html graphics}
		{/if}
		{#if writing}
			<br>
			<span class="role">Writing:</span> {@html writing}
		{/if}
		{#if credits.length > 0}
			{#each credits as credit, i}
				{#if i > 0}
					<br>
				{/if}
				<span class="role">{credit.role}:</span> {credit.names}
			{/each}
		{/if}
		<br>
		<span id="date">~ {date}</span>
	</p>

</div>


<style>

	.author-date {
		margin-top: 0px;
        border: solid 1px var(--brandGray);
		background-color: var(--brandWhite);
		/* border-bottom: solid 1px var(--brandGray); */
		margin-bottom: 0px;
		padding: 0px 20px 0px 20px;
        max-width: 680px;
		margin-bottom: 65px;
		
	}

	.author-date p {
		font-size: 14px;
		line-height: 24px;
		color: var(--brandGray90);
		font-family: OpenSans;
	}

	@media screen and (max-width: 600px) {
		.author-date p {
			font-size: 12px;
			line-height: 20px;
		}
	}


	.author-date b {
		color: var(--brandGray80);
		font-family: OpenSansBold;
		/* font-weight: normal; */
	}

	.author-date .role {
		color: var(--brandGray100);
		font-family: OpenSansBold;
		font-weight: normal;
	}

	.author-date #date {
		font-family: OpenSans;
		font-size: 13px;
		font-weight: normal;
	}

	.role {
		font-weight: bold;
	}

</style>