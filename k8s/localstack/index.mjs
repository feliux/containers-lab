console.log('Loading function');

export const handler = (event, context) => {
    event.Records.forEach(record => {
        let payload = Buffer.from(record.kinesis.data, 'base64').toString('ascii');
        console.log('Decoded payload:', payload);
    });
};
