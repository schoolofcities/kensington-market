<script>

	import "../assets/styles.css";

	export let authors = "";
	export let graphics = ""
	export let research = "";
	export let writing = "";
	export let date = "";
	export let credits = [];
	export let description = "";

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
				<span class="role">{credit.role}:</span>
				{#if credit.people}
					{#each credit.people as person, j}
						{#if j > 0}, {/if}
						{#if person.url}
							<a href={person.url} target="_blank">{person.name}</a>
						{:else}
							{person.name}
						{/if}
					{/each}
				{:else}
					{credit.names}
				{/if}
			{/each}
		{/if}
		<br>
		<span id="date" style="width: 100%; margin-bottom: 20px;">~ {date}</span>
		<br><br>
		{#if description}
			<span class="description">
				{@html description}
			</span>
		{/if}
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

	.author-date .description {
		margin-top: 16px;
		padding-top: 16px;
		/* border-top: 1px solid var(--brandGray); */
		font-size: 12px;
		line-height: 18px;
		color: var(--brandGray80);
	}

	.author-date p a {
		font-family: OpenSans !important;
		color: var(--brandGray90);
	}

	.author-date .description a {
		font-family: OpenSans !important;
		color: var(--brandGray80);
	}

	:global(.author-date a) {
		font-family: OpenSans !important;
	}

	:global(.author-date .description a) {
		color: var(--brandGray80) !important;
		font-family: OpenSans !important;
	}

	@media screen and (max-width: 600px) {
		.author-date .description {
			font-size: 11px;
			line-height: 16px;
		}
	}

</style>