const tabs = document.querySelectorAll('.tab');
const screens = document.querySelectorAll('.screen');

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    const target = tab.dataset.screen;

    tabs.forEach((t) => t.classList.remove('active'));
    screens.forEach((s) => s.classList.remove('active'));

    tab.classList.add('active');
    document.getElementById(target)?.classList.add('active');
  });
});
