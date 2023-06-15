({
	invoke: function (component) {

		var pageUrl = component.get("v.pageUrl");
		var urlString = window.location.href;
		var baseURL = urlString.substring(0, urlString.indexOf("/s"));

		setTimeout(() => {
			window.location = baseURL + pageUrl;
		}, 2000);

	}
})