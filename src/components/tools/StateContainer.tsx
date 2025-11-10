import React from "react";

export type StateStatus = "loading" | "error" | "empty" | "ready";

export interface StateContainerProps {
  status: StateStatus;
  children: React.ReactNode;
}

export default function StateContainer(props: StateContainerProps): JSX.Element {
  return <>{props.children}</>;
}


