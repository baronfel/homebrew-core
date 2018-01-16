class Msbuild < Formula
  desc "The MSBuild build agent, for Mono 5.4"
  homepage "https://msdn.microsoft.com/en-us/library/dd393574.aspx"
  # This commit SHA is the head of the mono-2017-06 branch, matched to Mono 5.4.
  # As mono advances versions, we should change to the HEAD of the tracking branch associated
  # with each version. eg. Mono 5.8 => mono-2017-10, Mono 5.10 => mono-2017-12
  url "https://github.com/mono/msbuild/archive/f296e67b6004dd39c3f43b177bcf45dfbe931341.zip"
  sha256 "52fa00eea34bf16cf4f690b0fe379459ebaa054506b0c817dab496d803149e41"

  depends_on "mono" => :required

  def install
    system "./cibuild.sh --scope Compile --target Mono --host Mono --config Release"
    system "./install-mono-prefix.sh #{Formula["mono"].opt_prefix}"
  end

  test do
    test_str = "Hello Homebrew"
    test_name = "hello.cs"
    (testpath/test_name).write <<~EOS
      public class Hello1
      {
         public static void Main()
         {
            System.Console.WriteLine("#{test_str}");
         }
      }
    EOS
    
    (testpath/"test.csproj").write <<~EOS
      <?xml version="1.0" encoding="utf-8"?>
      <Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
        <PropertyGroup>
          <AssemblyName>HomebrewMonoTest</AssemblyName>
          <TargetFrameworkVersion>v4.5</TargetFrameworkVersion>
        </PropertyGroup>
        <ItemGroup>
          <Compile Include="#{test_name}" />
        </ItemGroup>
        <Import Project="$(MSBuildBinPath)\\Microsoft.CSharp.targets" />
      </Project>
    EOS
    system bin/"msbuild", "test.csproj"
  end
end
