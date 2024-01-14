defmodule AppendFlickrFeedToS3.Application do
  @moduledoc false

  # Dialyzer tries to warn us that System.halt will always throw.
  # https://elixirforum.com/t/dialyzer-suppress-warning-on-a-specific-function/15048
  @dialyzer {:nowarn_function, start: 2}
  def start(_, _) do
    # args =
    #   case {System.argv(), Burrito.Util.Args.get_arguments()} do
    #     {[], args} -> args
    #     {[_ | args], _} -> args
    #   end
    run!()
    System.halt(0)
  end

  def run! do
    region = System.get_env("AWS_REGION")
    bucket = System.get_env("AWS_S3_BUCKET")
    key = System.get_env("AWS_S3_KEY")
    flickr_feed = System.get_env("FLICKR_FEED")
    access_key_id = System.get_env("AWS_ACCESS_KEY_ID")
    access_key = System.get_env("AWS_SECRET_ACCESS_KEY")

    IO.puts("Connecting using #{access_key_id}...")

    aws = AWS.Client.create(access_key_id, access_key, region)

    # Assumes flickr-photos.json already exists; otherwise you'll get
    # AccessDenied.
    # aws s3 cp --acl public-read ~/Downloads/photos.json "s3://jyc-static.com/flickr-photos.json"
    {:ok, _, %{:body => body}} = AWS.S3.get_object(aws, bucket, key)
    old_photos = Jason.decode!(body)

    %{:status => 200, :body => %{"items" => flickr_photos}} = Req.get!(flickr_feed)

    recent_photos =
      flickr_photos
      |> Map.new(fn p ->
        {p["link"], p |> Map.drop(["author", "author_id", "description", "link", "tags"])}
      end)

    # If an entry exists in both old_photos and recent_photos, the entry in
    # old_photos should take precedence so we never lose data.
    photos = Map.merge(recent_photos, old_photos)
    has_new_photos? = map_size(photos) > map_size(old_photos)

    if !has_new_photos? do
      IO.puts("No new photos; skipping.")
    else
      IO.puts("Found new photos; writing...")
      json = Jason.encode!(photos)
      md5 = :crypto.hash(:md5, json) |> Base.encode64()

      AWS.S3.put_object(aws, bucket, key, %{
        "Body" => json,
        "ContentMD5" => md5,
        "ACL" => "public-read",
        "ContentEncoding" => "utf8",
        "ContentType" => "application/json"
      })
    end
  end
end
