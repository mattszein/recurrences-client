export const TomselectHook = {
  mounted() {
    const selectEl = this.el;
    new TomSelect(selectEl, {
      plugins: ['checkbox_options', 'remove_button'],
      create: true,
      createFilter: "(^[+|-])([0-9])*([A-Z]{2})$|(^[A-Z]{2})$",
    });
  }
}
