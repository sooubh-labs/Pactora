from PIL import Image
import sys

def crop_transparency(image_path):
    print(f"Processing {image_path}")
    img = Image.open(image_path)
    img = img.convert("RGBA")
    
    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    
    if bbox:
        # Crop the image to the bounding box
        img_cropped = img.crop(bbox)
        # Add a small padding (e.g. 10%) so it's not touching the very edges
        w, h = img_cropped.size
        padding = int(max(w, h) * 0.1)
        
        new_w = w + padding * 2
        new_h = h + padding * 2
        
        # Create a new transparent image and paste the cropped one in the center
        new_img = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
        new_img.paste(img_cropped, (padding, padding))
        
        # Save back
        new_img.save(image_path)
        print(f"Cropped and padded {image_path} successfully. New size: {new_img.size}")
    else:
        print(f"{image_path} is completely empty/transparent.")

if __name__ == "__main__":
    crop_transparency("app-logo.png")
    crop_transparency("assets/images/app-logo.png")
