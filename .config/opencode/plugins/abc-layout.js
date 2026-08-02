export const ABCLayoutSwitcher = async ({ $ }) => {
  const switchToABC = () =>
    $`/opt/homebrew/bin/macism com.apple.keylayout.ABC`.nothrow().quiet();

  return {
    "chat.message": async () => {
      await switchToABC();
    },
    event: async ({ event }) => {
      if (
        event.type === "session.created" ||
        event.type === "permission.asked"
      ) {
        await switchToABC();
      }
    },
  };
};
