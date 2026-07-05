// Gates every /admin/* route behind a session check. /admin/login is the
// only exception — it has to be reachable by definition, and it does its
// own internal check to bounce already-logged-in visitors back to /admin.

export async function onRequest(context, next) {
  const { url, session, redirect } = context;

  if (url.pathname.startsWith('/admin') && url.pathname !== '/admin/login') {
    const adminId = await session.get('adminId');
    if (!adminId) {
      return redirect('/admin/login');
    }
  }

  return next();
}
