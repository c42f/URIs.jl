@testset "HTTP.URI" begin
    urls = ["hdfs://user:password@hdfshost:9000/root/folder/file.csv#frag",
        "https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag",
        "https://user:password@httphost:9000/path1/path2?q=a&p=r#frag",
        "https://user:password@httphost:9000/path1/path2;paramstring#frag",
        "https://user:password@httphost:9000/path1/path2#frag",
        "file:///path/to/file/with%3fshould%3dwork%23fine",
        "ftp://ftp.is.co.za/rfc/rfc1808.txt", "http://www.ietf.org/rfc/rfc2396.txt",
        "ldap://[2001:db8::7]/c=GB?objectClass?one", "mailto:John.Doe@example.com",
        "news:comp.infosystems.www.servers.unix", "tel:+1-816-555-1212", "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"]

    for url in urls
        u = parse(HTTP.URI, url)
        @test string(u) == url
        @test isvalid(u)
    end

    @test parse(HTTP.URI, "hdfs://user:password@hdfshost:9000/root/folder/file.csv") == HTTP.URI("hdfshost", "/root/folder/file.csv"; scheme="hdfs", port=9000, userinfo="user:password")
    @test parse(HTTP.URI, "http://google.com:80/some/path") == HTTP.URI("google.com", "/some/path")

    @test HTTP.escape("abcdef αβ 1234-=~!@#\$()_+{}|[]a;") == "abcdef%20%CE%B1%CE%B2%201234-%3D~%21%40%23%24%28%29_%2B%7B%7D%7C%5B%5Da%3B"
    @test HTTP.unescape(HTTP.escape("abcdef 1234-=~!@#\$()_+{}|[]a;")) == "abcdef 1234-=~!@#\$()_+{}|[]a;"
    @test HTTP.unescape(HTTP.escape("👽")) == "👽"

    @test "user:password" == HTTP.userinfo(parse(HTTP.URI, "https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag"))

    # @test ["dc","example","dc","com"] == HTTP.path_params(HTTP.URI("ldap://ldap.example.com/dc=example,dc=com"))[1]
    # @test ["servlet","jsessionid","OI24B9ASD7BSSD"] == HTTP.path_params(HTTP.URI("http://www.mysite.com/servlet;jsessionid=OI24B9ASD7BSSD"))[1]

    # @test Dict("q"=>"a","p"=>"r") == HTTP.query_params(HTTP.URI("https://httphost/path1/path2;paramstring?q=a&p=r#frag"))
    # @test Dict("q"=>"a","malformed"=>"") == HTTP.query_params(HTTP.URI("https://foo.net/?q=a&malformed"))

    @test false == isvalid(parse(HTTP.URI, "file:///path/to/file/with?should=work#fine"))
    @test true == isvalid( parse(HTTP.URI, "file:///path/to/file/with%3fshould%3dwork%23fine"))

    @test parse(HTTP.URI, "s3://bucket/key") == HTTP.URI("bucket", "/key"; scheme="s3")

    @test sprint(show, parse(HTTP.URI, "http://google.com")) == "HTTP.URI(\"http://google.com\")"

    # Error paths
    # Non-ASCII characters
    @test_throws HTTP.ParsingError parse(HTTP.URI, "http://🍕.com")
    # Unexpected start of URL
    @test_throws HTTP.ParsingError parse(HTTP.URI, ".google.com")
    # Unexpected character after scheme
    @test_throws HTTP.ParsingError parse(HTTP.URI, "ht!tp://google.com")

    #  Issue #27
    @test HTTP.escape("t est\n") == "t%20est%0A"
end; # @testset
