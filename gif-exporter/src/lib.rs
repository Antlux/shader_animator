
use godot::{obj::cap::GodotDefault, prelude::*};

pub struct AnimationExporterLibrary;

#[gdextension]
unsafe impl ExtensionLibrary for AnimationExporterLibrary {}



#[derive(GodotClass)]
#[class(base=Object)]
struct AnimationExporter {}

impl GodotDefault for AnimationExporter {}

#[godot_api]
impl AnimationExporter {
    #[func]
    fn encode_gif(width: u32, height: u32, delay: f32, frames: Vec<PackedByteArray>) -> PackedByteArray {
        
        let width = width as u16;
        let height = height as u16;
        let mut buffer = vec![];
    

        if let Ok(mut encoder) = gif::Encoder::new(
            &mut buffer, 
            width, 
            height, 
            &[]
        ) {

            if encoder.set_repeat(gif::Repeat::Infinite).is_err() {
                return PackedByteArray::new();
            };

            for mut pixels in frames {
                let mut frame = gif::Frame::from_rgba(
                    width, 
                    height, 
                    pixels.as_mut_slice()
                );
                frame.delay = (delay * 100.0) as u16;
                frame.dispose = gif::DisposalMethod::Background;

                if encoder.write_frame(&frame).is_err() {
                    return PackedByteArray::new();
                }
            }
        } else {

            return PackedByteArray::new();

        }

        
        PackedByteArray::from(buffer)
    }
}
