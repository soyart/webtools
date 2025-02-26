document.addEventListener("DOMContentLoaded", function(_) {
	// Get the navbar
	const navbar = document.getElementById("navbar");

	// Get the offset position of the navbar
	const sticky = navbar.offsetTop;

	// Add the sticky class to the navbar when you reach its scroll position. Remove "sticky" when you leave the scroll position
	function sticknav() {
		if (window.scrollY >= sticky) {
			navbar.classList.add("sticky")
			return
		}

		navbar.classList.remove("sticky");
	}

	// When the user scrolls the page, exec sticknav()
	window.onscroll = function() {
		sticknav()
	};
});
