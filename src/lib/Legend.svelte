<script>
  import { visibleCategories } from '$lib/stores';
  export let categories = []; // unique values from dataset

  function toggleCategory(cat) {
    visibleCategories.update(set => {
      if (set.has(cat)) set.delete(cat);
      else set.add(cat);
      return new Set(set);
    });
  }
</script>

{#each categories as cat}
  <button on:click={() => toggleCategory(cat)}
          class:selected={visibleCategories.includes(cat)}>
    {cat}
  </button>
{/each}
