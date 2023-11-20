//@ts-check

export {};
import { parseArgs } from "node:util";
const RENDER_API_KEY = process.env.RENDER_API_KEY;
const RENDER_SERVICE_ID = process.env.RENDER_SERVICE_ID;
const RENDER_DEPLOY_HOOK = process.env.RENDER_DEPLOY_HOOK;

const { values } = parseArgs({
	options: {
		tag: {
			type: "string",
			short: "t",
		},
		image: {
			type: "string",
			short: "i",
		},
	},
});
if (!values.tag) {
	throw new Error("tag is not set");
}
if (!values.image) {
	throw new Error("image is not set");
}
const { tag, image } = values;

if (!RENDER_API_KEY) {
	throw new Error("RENDER_API_KEY is not set");
}
if (!RENDER_SERVICE_ID) {
	throw new Error("RENDER_SERVICE_ID is not set");
}
if (!RENDER_DEPLOY_HOOK) {
	throw new Error("RENDER_DEPLOY_HOOK is not set");
}

const options = {
	method: "PATCH",
	headers: {
		accept: "application/json",
		"content-type": "application/json",
		authorization: `Bearer ${RENDER_API_KEY}`,
	},
	body: JSON.stringify({
		image: {
			imagePath: `${image}:${tag}`,
			ownerId: image.split("/")[0],
		},
	}),
};

try {
	const response = await fetch(
		`https://api.render.com/v1/services/${RENDER_SERVICE_ID}`,
		options,
	);
	if (response.ok) {
		// const data = await response.json();
		console.log(`Succesfully update service with tag ${tag}`);
	} else {
		throw new Error("Error updating");
	}
} catch (err) {
	console.error(err);
}

try {
	const response = await fetch(`${RENDER_DEPLOY_HOOK}`, { method: "GET" });
	if (response.ok) {
		// const data = await response.json();
		console.log("Succesfully deploy service using deploy hook");
	} else {
		throw new Error("Error deploying");
	}
} catch (err) {
	console.error(err);
}
