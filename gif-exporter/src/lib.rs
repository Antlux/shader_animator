use godot::{obj::cap::GodotDefault, prelude::*};

pub struct AnimationExporterLibrary;

#[gdextension]
unsafe impl ExtensionLibrary for AnimationExporterLibrary {}


use std::{fs::File, path::PathBuf};

#[derive(GodotClass)]
#[class(base=Object)]
struct AnimationExporter {}

impl GodotDefault for AnimationExporter {}




#[godot_api]
impl AnimationExporter {
    #[func]
    fn export_gif(path_str: String, width: u32, height: u32, delay: f32, frames: Vec<PackedByteArray>) {
        
        let width = width as u16;
        let height = height as u16;

        let path = PathBuf::from(path_str);
    
        if let Ok(mut exported_image) = File::create(path) {
            if let Ok(mut encoder) = gif::Encoder::new(
                &mut exported_image, 
                width, 
                height, 
                &[]
            ) {
                encoder.set_repeat(gif::Repeat::Infinite).unwrap();
                for mut pixels in frames {
                    let mut frame = gif::Frame::from_rgba(
                        width, 
                        height, 
                        pixels.as_mut_slice()
                    );
                    frame.delay = (delay * 100.0) as u16;
                    encoder.write_frame(&frame).unwrap()
                }
            }
        }
    
    }

    #[func]
    fn export_webp(path_str: String, width: u32, height: u32, delay: f32, frames: Vec<PackedByteArray>) {
        let path = PathBuf::from(path_str);
        let dimensions = (width, height);
        let final_timestamp_ms = (frames.len() as f32 * delay * 1000.0) as i32;

        if let Ok(mut encoder) = webp_animation::Encoder::new(dimensions) {
            for (i, mut pixels) in frames.into_iter().enumerate() {
                let data = pixels.as_mut_slice();
                let timestamp_ms = (i as f32 * delay * 1000.0) as i32;
                godot_print!("{}", timestamp_ms);
                encoder.add_frame(data, timestamp_ms).unwrap();
            }

            let webp_data = encoder.finalize(final_timestamp_ms).unwrap();
            std::fs::write(path, webp_data).unwrap()
        }
    }
}
