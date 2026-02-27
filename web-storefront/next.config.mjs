export default function nextConfig(phase) {
  const isDevServer = phase === 'phase-development-server';
  return {
    distDir: isDevServer ? '.next-dev' : '.next',
  };
}
