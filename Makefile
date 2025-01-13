workspace:
	docker compose up

proxy:
	ngrok http --config=/home/node/.config/ngrok/ngrok.yml --url willingly-sunny-glider.ngrok-free.app localhost:3000

recreate-workspace:
	docker compose up --build --force-recreate
