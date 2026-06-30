import { React, ReactNative } from "@vendetta/metro/common";

const { View, Text } = ReactNative;

export default () =>
    React.createElement(
        View,
        { style: { padding: 16 } },
        React.createElement(Text, null, "Hello, world!"),
    );
