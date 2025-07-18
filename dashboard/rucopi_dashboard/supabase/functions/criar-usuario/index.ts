import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { nome, email, cargo } = await req.json()
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Verifique se o usuário autenticado é admin
  const jwt = req.headers.get('Authorization')?.replace('Bearer ', '')
  const { data: userData } = await supabase.auth.getUser(jwt)
  const userId = userData?.user?.id
  const { data: usuario } = await supabase
    .from('usuarios')
    .select('cargo')
    .eq('id', userId)
    .single()
  if (!usuario || usuario.cargo !== 'administrador') {
    return new Response(JSON.stringify({ error: 'not_admin' }), { status: 403 })
  }

  // Crie o usuário no Auth
  const { data, error } = await supabase.auth.admin.createUser({
    email,
    email_confirm: false,
  })
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }

  // Crie o usuário na tabela usuarios
  await supabase.from('usuarios').insert({
    id: data.user.id,
    nome,
    cargo,
    permissoes: {},
  })

  return new Response(JSON.stringify({ success: true }), { status: 200 })
})