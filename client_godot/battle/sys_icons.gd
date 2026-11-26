extends RefCounted



const SVG: Dictionary = {
	"mic": "<rect x=\"8.6\" y=\"1.8\" width=\"6.8\" height=\"12.4\" rx=\"3.4\" fill=\"{c}\"/><path d=\"M5.2 10.8a6.8 6.8 0 0 0 13.6 0\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M12 17.8v3.4M8.4 21.6h7.2\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"mic_off": "<rect x=\"8.6\" y=\"1.8\" width=\"6.8\" height=\"12.4\" rx=\"3.4\" fill=\"{c}\"/><path d=\"M5.2 10.8a6.8 6.8 0 0 0 13.6 0\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M12 17.8v3.4M8.4 21.6h7.2\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M3.4 3.4l17.2 17.2\" stroke=\"{d}\" stroke-width=\"2.8\" stroke-linecap=\"round\"/>", 
	"spk": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.4 8.4a5 5 0 0 1 0 7.2M18.4 5.4a9.2 9.2 0 0 1 0 13.2\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"spk_room": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.4 8.4a5 5 0 0 1 0 7.2\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"menu": "<path d=\"M4.6 6.4h14.8M4.6 12h14.8M4.6 17.6h14.8\" stroke=\"{c}\" stroke-width=\"2.7\" stroke-linecap=\"round\"/>", 
	"spk_off": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.2 9l6 6M21.2 9l-6 6\" stroke=\"{d}\" stroke-width=\"2.6\" stroke-linecap=\"round\"/>", 
}

static func texture(name: String, size: float, c: Color, d: Color) -> ImageTexture:
	if not SVG.has(name):
		return null
	var body: String = str(SVG[name]).replace("{c}", "#" + c.to_html(false)).replace("{d}", "#" + d.to_html(false))
	var svg: String = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\">" + body + "</svg>"
	var img: Image = Image.new()
	if img.load_svg_from_string(svg, size / 24.0) != OK:
		return null
	return ImageTexture.create_from_image(img)
