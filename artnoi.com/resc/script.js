document.addEventListener("DOMContentLoaded", function(_) {
	// When the user scrolls the page, exec sticknav()
	window.onscroll = function() {
		console.log("onscroll")
		sticknav()
	};

	// Get the navbar
	var navbar = document.getElementById("navbar");
	console.log("foo", navbar)

	// Get the offset position of the navbar
	var sticky = navbar.offsetTop;

	// Add the sticky class to the navbar when you reach its scroll position. Remove "sticky" when you leave the scroll position
	function sticknav() {
		console.log("scrollY", window.scrollY, "sticky", sticky)
		if (window.scrollY >= sticky) {
			console.log("adding sticky", navbar.classList)
			navbar.classList.add("sticky")
			return
		}

		console.log("removing sticky", navbar.classList)
		navbar.classList.remove("sticky");
	}
});
