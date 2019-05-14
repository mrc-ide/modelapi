## modelapi

Bring up redis and the modelapi container on the host network (this will expose ports 6379 and 8000 with no authentication and we should move these into a network, but that requires a bit more configuration control

``` shell
docker run --rm -d --network=host --name modelapi_redis redis
docker run --rm -d --network=host --name modelapi_model mrcide/modelapi:latest
```

Test that all is ok:

``` shell
curl http://localhost:8000
```

Validate input data:

``` shell
curl -X POST -H 'Content-Type: application/json' \
     --data @example/payload-err.json http://localhost:8000/validate
#> {"success":false,"error":"argument \"parameters\" is missing, with no default"}
curl -X POST -H 'Content-Type: application/json' \
     --data @example/payload.json http://localhost:8000/validate
#> {"success":true,"error":null}
```

Queue a model

``` shell
curl -X POST -H 'Content-Type: application/json' \
     --data @example/payload.json http://localhost:8000/model/submit
#> "e9988060c6db214177d130b240664eb1"
```

Query the model status

``` shell
curl http://localhost:8000/model/e9988060c6db214177d130b240664eb1/status
#> {"done":true,"status":"COMPLETE","success":true,"queue":0}
```

Get model results

``` shell
curl http://localhost:8000/model/e9988060c6db214177d130b240664eb1/result | jq .

#> {
#>   "fitted": {
#>     "a": [
#>       40
#>     ],
#>     "b": [
#>       9
#>     ]
#>   },
#>   "simulation": [
#>     {
#>       "t": 0,
#>       "y": 0,
#>       "z": 0.5122
#>     },
#>     {
#>       "t": 0.1579,
#>       "y": 0.1572,
#>       "z": 0.8947
#>     },
#>     {
#>       "t": 0.3158,
#>       "y": 0.3106,
```
