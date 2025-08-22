<script>
  import { selectedYear } from '$lib/stores'; // store from stores.js

  let years = [2025, 2020, 2019, 2015, 2011, 2007, 1989];
</script>

<label for="year-select">Year:</label>
<select id="year-select" bind:value={$selectedYear}>
  {#each years as year}
    <option value={year}>{year}</option>
  {/each}
</select>
