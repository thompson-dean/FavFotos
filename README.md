# FavFotos 🚀
FavFotos is an iOS application that allows users to search and view photos from the Pexels API. The app supports features like viewing photo details, changing photo quality, and saving photos to favorites.

![Screenshot of App Main Screen](FavFotos/screenshots/screenshot01.mp4)

## Features 🌟
- **Curated Photos**: Scroll through Pexel's curated list of photos.
- **Search Photos**: Type in a keyword and browse a list of related photos from Pexels.
- **Endless SCrolling**: Added pagination for endless scrolling.
- **Photo Details**: Each photo can be inspected in their detail view.
- **Change Quality**: Adjust the quality of the photos you're viewing to suit your preference.
- **Image Caching**: To save the user's precious data.
- **Favorites**: Save your favorite photos to view them again later.
- **Intuitive UI**: Custom collection view layout.

## Requirements 📋
- **iOS**: 16.0 or above.
- **Xcode**: 14+
- **Dependencies**: No external CocoaPods or SPM dependencies.

## Getting Started 🚀

### Installation 💾

1. Clone the repository:
   ```bash
   git clone https://github.com/thompson-dean/FavFotos.git
   ```
2. Open the `.xcodeproj` file in Xcode.
3. Ensure you've set up your Pexels API key as instructed below.
4. Build and run the project on your preferred simulator or actual device.

### Pexels API Key Setup 🔑

After obtaining your API key from [Pexels](https://www.pexels.com/api/documentation/):

1. Navigate to the app's `Constants.swift` file.
2. Find the placeholder for the API key.
3. Replace the placeholder with your actual Pexels API key.

## Architecture & Design 🏛

The app adopts the MVVM (Model-View-ViewModel) architecture, ensuring a clean and maintainable codebase. MVVM promotes a clear separation of concerns and allows for more efficient unit testing.

The app utilizes Swift Combine for reactive programming, making handling of network requests and UI updates seamless and intuitive.

## Tests 🧪
Added Unit Tests for safety and future proofing of the application.

## Future Work & Enhancements 💡

While the current implementation serves its core purpose, here are some potential improvements:

- Introducing a dark mode toggle for better user experience in different lighting conditions.
- Adding an Information button to the photos to get more details about them.
- I would have also liked to add deeper error handling for the CoreData part of my project.
- If I had more time to complete the project I would have been more considerate with git and would have used a variation of git-flow.

## License 📄

This project is distributed under the MIT License.  
