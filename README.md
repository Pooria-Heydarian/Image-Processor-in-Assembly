# Image-Processor-in-Assembly
This project is an **Image Processor** designed and implemented in assembly language.
# Assembly Image Processor

## Introduction

This project is an **Image Processor** designed in assembly language. It allows users to perform a variety of image processing operations, such as resizing, reshaping, grayscale conversion, applying convolutional filters, and pooling. The project showcases the efficiency of assembly language in handling image data and performing complex operations with precision.

## Features

1. **Resizing**: Change the dimensions of the input image to a specified width and height.
2. **Reshaping**: Alter the shape of the image while maintaining the number of pixels, potentially changing its aspect ratio.
3. **Grayscale Conversion**: Convert the image from color to grayscale by averaging the color channels.
4. **Convolutional Filters**:
   - **Sharpening**: Enhance the edges and fine details of the image to make it appear sharper.
   - **Emboss**: Apply an embossing effect to give the image a three-dimensional texture.
5. **Pooling**:
   - **Average Pooling**: Reduce the dimensions of the image by averaging the pixels in each pooling region.
   - **Max Pooling**: Reduce the dimensions of the image by selecting the maximum pixel value in each pooling region.
6. **Output Image**: Save the processed image after applying the selected transformations.

## Project Structure

- **app.asm**: The main assembly file containing the logic for all image processing operations.
- **data**: An image that may contain sample input images for testing.


## Prerequisites

- **Assembler**: Ensure you have an assembler that supports the syntax used in `app.asm`. Common choices include NASM or MASM.
- **Image Viewer**: Use an image viewer to view the input and output images processed by this program.

## Acknowledgements

- **Inspiration**: Inspired by the need for efficient image processing in low-level programming environments.
- **Support**: Thanks to the community for providing resources and guidance on assembly programming.
