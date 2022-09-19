﻿param([string]$version = "5.2.1")

cd $PSScriptRoot;
mkdir -Force -Verbose builds;
cd builds;
mkdir -Force -Verbose x86;
mkdir -Force -Verbose x64;

foreach ($language in @{
	ENGLISH="";
	# SPANISH="Spanish";
	# SIMPLIFIED_CHINESE="Simplified-Chinese";
	# RUSSIAN="Russian";
	# TURKISH="Turkish";
	# INDONESIAN="Indonesian";
	# PORTUGUESE="Portuguese";
	# THAI="Thai";
	# KOREAN="Korean";
	# ITALIAN="Italian";
	# FRENCH="French"
}.GetEnumerator())
{
	$folder = "Textractor-$($language.Value)-$version";
	if (Test-Path $folder) {
		Remove-Item -Force -Recurse -Verbose $folder;
	}

	mkdir -Force -Verbose $folder;

	foreach ($arch in @("x86"))
	# foreach ($arch in @("x86", "x64"))
	{
		cd $arch;
		$VS_arch = if ($arch -eq "x86") {"Win32"} else {"x64"};
		&"C:\Program Files\Microsoft Visual Studio\2022\Preview\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" -G "Visual Studio 17 2022" -A"$VS_arch" -DVERSION="$version" -DTEXT_LANGUAGE="$($language.Key)" -DCMAKE_BUILD_TYPE="Release" ../..;
		&"C:\Program Files\Microsoft Visual Studio\2022\Preview\Common7\IDE\devenv" Textractor.sln /build "Release|$VS_arch";
		cd ..;
		mkdir -Force -Verbose "$folder/$arch";
		foreach ($file in @(
			"Textractor.exe",
			"TextractorCLI.exe",
			"texthook.dll"
		))
		{
			copy -Force -Recurse -Verbose -Destination "$folder/$arch" -Path "Release_$arch/$file";
		}
		foreach ($extension in @(
			"Bing Translate",
			"Copy to Clipboard",
			"DeepL Translate",
			"DevTools DeepL Translate",
			"DevTools Papago Translate",
			"DevTools Systran Translate",
			"Extra Newlines",
			"Extra Window",
			"Google Translate",
			"Lua",
			"Regex Filter",
			"Regex Replacer",
			"Regex Replacer Process Hooked",
			"Remove Repeated Characters",
			"Remove Repeated Leading Sentence",
			"Remove Repeated Phrases",
			"Remove Repeated Phrases 2",
			"Remove 30 Repeated Sentences",
			"Replacer",
			"Replacer Process Hooked",
			"Styler",
			"Thread Linker",
			"Yandex Translate"
			"Sugoi Offline Translate"
		))
		{
			copy -Force -Recurse -Verbose -Destination "$folder/$arch/$extension.xdll" -Path "Release_$arch/$extension.dll";
		}
	}
	&"C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe" sign /a /v /t "http://timestamp.digicert.com"  /fd SHA256 @(dir "$folder\**\*");
}

rm -Force -Recurse -Verbose "Runtime";
mkdir -Force -Verbose "Runtime";
# foreach ($arch in @("x86", "x64"))
foreach ($arch in @("x86"))
{
	mkdir -Force -Verbose "Runtime/$arch";
	foreach ($file in @(
		"LoaderDll.dll",
		"LocaleEmulator.dll",
		"Qt5Core.dll",
		"Qt5Gui.dll",
		"Qt5Network.dll",
		"Qt5WebSockets.dll",
		"Qt5WinExtras.dll"
		"Qt5Widgets.dll",
		"platforms",
		"styles"
	))
	{
		copy -Force -Recurse -Verbose -Destination "Runtime/$arch/$file" -Path "Release_$arch/$file";
	}
	copy -Force -Recurse -Verbose -Destination "Runtime/$arch" -Path "C:\Program Files\Microsoft Visual Studio\2022\Preview\VC\Redist\MSVC\**\$arch\Microsoft.VC142.CRT\*"
}

rm -Force -Recurse -Verbose "Textractor";
mkdir -Force -Verbose "Textractor";
copy -Force -Recurse -Verbose -Destination "Textractor" -Path @("Runtime/*", "Textractor--$version/*");
&"C:\Program Files\7-Zip\7z" a "Textractor-$version-Zip-Version-English-Only.zip" Textractor/ ../INSTALL_THIS_UNICODE_FONT.ttf

cd ..;
# &"C:\Program Files (x86)\Inno Setup 6\iscc" -DVERSION="$version" installer.iss;
# &"C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe" sign /a /v /t "http://timestamp.digicert.com"  /fd SHA256 "Builds/Textractor-$version-Setup.exe";
