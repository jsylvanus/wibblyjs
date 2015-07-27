# Wibbly.js

Canvas-based javascript component for creating backgrounds masked at the top and/or bottom with bezier curves.

## Markup Usage

Create an element with the following attributes:

### (required) data-background="type params..."

A space-separated list of parameters starting with the type of background to use. Valid types:

* **image**: second parameter should be the image path. The image will be stretched to fill the container, maintaining aspect ratio.

        <div data-background="image https://your-domain/your-image.png">...</div>

* **solid**: used for solid backgrounds; 2nd parameter is anything conforming to the [CSS <color\> value](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value).

        <div data-background="solid #000">...</div>

### (optional) data-top="<bezier values\>", data-bottom="<bezier values\>"

<bezier values\> is a series of eight floating point numbers representing a bezier curve from left to right. -top and -bottom determine which curve you're specifying. 
Both of these attributes are optional, but you should specify one or both, otherwise you've just got a box...

Example:

	<section id="curve-me" data-top="0 0.5 0.33 1 0.66 0 1 0.5" data-background="solid #000">
		...
	</section>

## Javascript Usage

With the Markup Usage section satisfied, simply instantiate a new WibblyElement object for each element you have set up.

In simplest form, `new WibblyElement(document.querySelector('#curve-me'));` from the example above.

For jQuery (which is not required), you might do something like:

	jQuery(function($) {
		$('.wibbly').each(function(idx,el) {
			new WibblyElement(el);
		});
	});