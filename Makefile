#
# Example usage
#
# PAIR=binance.ETH-BTC make backfill
# PAIR=binance.ETH-BTC make sim
#

AWS_PROFILE ?= del
PAIR ?= binance.ETH-BTC

default: run

clean:
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /etc:/etc:ro spotify/docker-gc

conf:
	@[ -f ./conf.js ] && echo 'Using existing conf.js file!' || ( cp ./conf-sample.js ./conf.js )

run: conf
	docker-compose up --build

pairs:
	docker-compose exec server zenbot list-selectors

strats:
	docker-compose exec server zenbot list-strategies

backfill:
	# docker-compose exec server zenbot backfill <selector> --days <days>
	docker-compose exec server zenbot backfill $(PAIR) --days 7

sim:
	# docker-compose exec server zenbot sim <selector> [options]
	docker-compose exec server zenbot sim $(PAIR) # --strategy bollinger

upload:
	cd simulations; aws s3 sync . s3://earth-pub --profile $(AWS_PROFILE)

.PHONY: clean conf run pairs strats backfill sim upload
