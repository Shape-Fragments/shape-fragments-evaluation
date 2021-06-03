Commands used to generate queries:
```
docker run --rm -it -v $(pwd)/queries/watdiv/:/output comunica/watdiv -s 10 -q 1 -r 1
for i in *.txt; do mv $i ${i:0:3}rq; done
sed -i -e 's/SELECT .* WHERE/CONSTRUCT WHERE/g' *.rq
```
