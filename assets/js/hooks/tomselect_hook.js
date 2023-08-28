export const TomselectHook = {
  mounted() {
    const selectEl = this.el;
    new TomSelect(selectEl, {
      plugins: ['checkbox_options', 'remove_button'],
    });
  }
}
