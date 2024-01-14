# AppendFlickrFeedToS3

Get the most recent images from a Flickr feed and append them to a JSON file in S3.

```console
$ cat > .env
AWS_REGION=us-west-2
AWS_S3_BUCKET=jyc-static.com
AWS_S3_KEY=flickr-photos.json
FLICKR_FEED=https://www.flickr.com/services/feeds/photos_public.gne?id=48168967@N00&lang=en-us&format=json&nojsoncallback=1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
^D

echo '{}' > photos.json
aws s3 cp --acl public-read photos.json "s3://jyc-static.com/flickr-photos.json"

mix deps.get
./start
```

Assumes you have an S3 bucket and IAM user set up with the appropriate permissions.
`iam-policy.json` contains an example IAM policy.

To build a statically-linked binary:

```
./release
./start-release
```

Other useful commands:

- `./repl`
- `./fmt`
- `./lint`
