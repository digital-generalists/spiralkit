# SpiralKit by Digital Generalists

*A drawing framework for iOS*

## What Is SpiralKit

[SpiralKit](http://digitalgeneralists.com/spiralkit) is a drawing framework for iOS written in Objective-C. The framework enables drawing on a UIView in iOS and ships with pen, highlighter, and eraser drawing effects.

The framework is built specifically to enable adding new effects, color spaces, and drawing algorithms in a modular fashion. If you want to provide a unique drawing effect, support of the CMYK color space, or add a custom drawing algorithm, you can add such features to [SpiralKit](http://digitalgeneralists.com/spiralkit) without having to modify the fundamental components of the framework in most cases.

## Documentation

Complete documentation for SpiralKit can be found [here](http://digitalgeneralists.com/spiralkit/documentation).

## License

[SpiralKit](http://digitalgeneralists.com/spiralkit) is released under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

See the [`LICENSE.txt`](LICENSE.txt) file for the formal license specification.

## Prerequisites and Supported Versions

### Prerequisites

[SpiralKit](http://digitalgeneralists.com/spiralkit) is an iOS-specific framework.  To build and use [SpiralKit](http://digitalgeneralists.com/spiralkit), you need to have Xcode installed.  

The provided Xcode project files are generated from Xcode 6.3.1.

* Xcode \[[download](https://developer.apple.com/xcode/)\]

Xcode should be the only prerequisite for using [SpiralKit](http://digitalgeneralists.com/spiralkit).  If you want to run [SpiralKit](http://digitalgeneralists.com/spiralkit) on a device, you’ll need an iOS device.

### Supported Versions

The code for [SpiralKit](http://digitalgeneralists.com/spiralkit) is verified back to iOS 8.0.  Theoretically, the functional code should be portable back to iOS 5.1.

Feel free to attempt to take [SpiralKit](http://digitalgeneralists.com/spiralkit) back all the way to 5.1, but there may be compiler warnings and the provided build scripts and project files likely won't function as intended for builds targeting versions of iOS prior to 8.0.

The best bet for pre-iOS 8 integration of the framework is direct incorporation of the [SpiralKit](http://digitalgeneralists.com/spiralkit) source into your application binary.

## IDE

[SpiralKit](http://digitalgeneralists.com/spiralkit) was developed using Xcode 4.3.2 through 6.3.1.  Project files for Xcode 6.3.1 are included with the distribution.

## Building and Packaging

[SpiralKit](http://digitalgeneralists.com/spiralkit) uses Xcode build profiles linked to shell scripts as its primary build system.  


### Building the Framework

#### Building for Development Environments

To build the framework for development:

	Open the SpiralKit project in Xcode
	Select the 'Development' build profile
	Press 'Cmd+B'
	
The `Development` build profile will create a debug build of the framework with a `DEVBUILD` build number.  The `DGSKLog` macro will output logging statements via `NSLog` in these builds.

#### Building for Internal Test Environments

To build the framework for internal release (for QA or beta testing for example):

	Open the SpiralKit project in Xcode
	Select the 'Internal Release' build profile
	Press 'Cmd+B'
	
The `Internal Release` build profile will create a release build of the framework with an `INT` build number prefix.  The `DGSKLog` macro will not output any logging statements in these builds.

#### Building for Public Release

To build the framework for public release:

	Open the SpiralKit project in Xcode
	Select the 'Public Release' build profile
	Press 'Cmd+B'
	
The `Public Release` build profile will create a release build of the framework without the `INT` build number prefix.  The `DGSKLog` macro will not output any logging statements in these builds.

### Packaging the Framework

Building the framework will create a working version of [SpiralKit](http://digitalgeneralists.com/spiralkit) that can be used within the iOS simulator. However, finding and configuring an optimized version of the built framework for inclusion in an application requires some additional work. The packaging build profiles simplify and largely automate these tasks.

#### Packaging as a Universal Binary

The `Create-[release profile]-Universal-Framework` build profiles will create a version of the framework that will run on both iOS devices and the Xcode simulator.

To package the framework as a Universal binary:

	Open the SpiralKit project in Xcode
	Select the appropriate 'Development', 'Internal Release', or 'Public Release' build profile
	Select the iOS Device build target
	Press 'Cmd+B'
	Select any iOS simulator build target
	Press 'Cmd+B'
	Select the appropriate 'Create-[release profile]-Universal-Framework' build profile
	Press 'Cmd+B'
		
`Create-[release profile]-Universal-Framework` build profiles are provided for `Development`, `Internal Release`, and `Public Release` release profiles.  The `Create-[release profile]-Universal-Framework` build profiles require that both the Xcode simulator and iOS device builds are done prior to running a `Create-[release profile]-Universal-Framework` build profile.

The packaged framework will be created in the `[SpiralKit project root]/build_ouput` directory.

#### Packaging as an iOS-Only Binary

The `Create-[release profile]-iOS-Only-Framework` build profiles will create a version of the framework that will run only on iOS devices. This may be valuable for release versions of an application as the created binary is significantly smaller than the universal binary version.

To package the framework as an iOS-only binary:

	Open the SpiralKit project in Xcode
	Select the appropriate 'Development', 'Internal Release', or 'Public Release' build profile
	Select the iOS Device build target
	Press 'Cmd+B'
	Select the appropriate 'Create-[release profile]-iOS-Only-Framework' build profile
	Press 'Cmd+B'
	
`Create-[release profile]-iOS-Only-Framework` build profiles are provided for `Development`, `Internal Release`, and `Public Release` release profiles.  The `Create-[release profile]-iOS-Only-Framework` build profiles require that the iOS device build is done prior to running a `Create-[release profile]-iOS-Only-Framework` build profile.

The packaged framework will be created in the `[SpiralKit project root]/build_ouput` directory.

## Including SpiralKit in an Application

To include a built version of the [SpiralKit](http://digitalgeneralists.com/spiralkit) framework in an application:

- Build and package a version of the framework as described above
- Create a new application via Xcode
- Open the new project in Xcode
- Select the project file and click **General** in the code editor window
- Find the **Embedded Binaries** section and click the **+** button
- Navigate to the directory containing the local copy of the [SpiralKit](http://digitalgeneralists.com/spiralkit) framework that was just built and select **SpiralKit.framework**
- In any file that references an API, class, or protocol from the framework, add an import statement for the [SpiralKit](http://digitalgeneralists.com/spiralkit) framework to the referencing source file.  This is essentially the same operation you would perform for a pre-packaged iOS-framework such as UIKit.

        #import <SpiralKit/SpiralKit.h>

- Create data provider classes to manage the drawing operations

All provided cache-based drawing algorithms require a data provider class that complies with the [`DGSKCacheDrawDataProviderProtocol`](./SpiralKit/SpiralKit/DGSKCacheDrawDataProviderProtocol.h) protocol.

All provided stroke-based drawing algorithms require a data provider class that complies with the [`DGSKStrokeDrawDataProviderProtocol`](/SpiralKit/SpiralKit/DGSKStrokeDrawDataProviderProtocol.h) protocol.

Both [`DGSKCacheDrawDataProviderProtocol`](/SpiralKit/SpiralKit/DGSKCacheDrawDataProviderProtocol.h) and [`DGSKStrokeDrawDataProviderProtocol`](/SpiralKit/SpiralKit/DGSKStrokeDrawDataProviderProtocol.h) inherit from [`DGSKDrawDataProviderProtocol`](/SpiralKit/SpiralKit/DGSKDrawDataProviderProtocol.h).

These protocols can be mixed within the same class, meaning that cache-based and stroke-based drawing algorithms can share the same data provider assuming the class implements both protocols.

See the SpiralKitReference application for a basic implementation of a class implementing both protocols or the [SpiralKit documentation](http://digitalgeneralists.com/spiralkit/documentation) for complete information on implementing the protocols.

- Wire [SpiralKit](http://digitalgeneralists.com/spiralkit) into the application

		/***/
		@implementation ViewController

		//@property (strong, nonatomic) UIView *drawView;
		@synthesize drawView = _drawView;
		//@property (strong, nonatomic) DrawData* drawData;
		@synthesize drawData = _drawData;

		- (void)viewDidLoad
		{
			[super viewDidLoad];

			[self.view setBackgroundColor:[UIColor whiteColor]];

			self.drawData = [[DrawData alloc] init];
			// This can be substituted with any DGSKDrawViewProtool-compliant implementation of UIView.
			self.drawView = [[DGSKDrawView alloc] initWithFrame:self.view.frame];

			id stylingProvider = [DGSKDrawContextStylingProviderFactory createInstanceForDrawToolType:DGSKDrawToolTypeNormal];
			stylingProvider.color = [UIColor blackColor];
			stylingProvider.lineWidth = 2;
			[stylingProvider.effectsEngine calibrateToStylingProvider:stylingProvider];

			// Returns the draw engine instance if you need to track it.
			[DGSKDrawEngineFactory createInstanceForDrawView:self.drawView withStylingProvider:stylingProvider data:self.drawData];

			[self.view insertSubview:self.drawView atIndex:0];
		}

		/***/
		@end

That's it. After performing the above steps, you should be able to draw on the inserted 'drawView' UIView instance within your application's UI.

See the SpiralKitReference application for a basic implementation of a ViewController implementing [SpiralKit](http://digitalgeneralists.com/spiralkit) or the [SpiralKit documentation](http://digitalgeneralists.com/spiralkit/documentation) for complete information on implementing [SpiralKit](http://digitalgeneralists.com/spiralkit).

## The Reference Implementation

The [SpiralKit](http://digitalgeneralists.com/spiralkit) reference implementation provides a very simple implementation of including [SpiralKit](http://digitalgeneralists.com/spiralkit) in an application and should be used to provide guidance on how to incorporate [SpiralKit](http://digitalgeneralists.com/spiralkit) into an application.

The reference implementation links to a pre-compiled universal instance of the [SpiralKit](http://digitalgeneralists.com/spiralkit) framework. This provided build of the framework linked to the reference implementation can be found at `[reference implementation source directory]/framework-releases`.

## Acknowledgments

The original implementation of [SpiralKit](http://digitalgeneralists.com/spiralkit) was influenced by [this post](http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/).  The final implementation is deeply spiked from the one provided in the article, but we want to give credit for the initial direction.

The Douglas-Peucker algorithm implementation methods in this framework are based on work from https://github.com/andreac/lineSmooth.

*Copyright © 2015 - 2023 [Digital Generalists, LLC.](http://digitalgeneralists.com)*
