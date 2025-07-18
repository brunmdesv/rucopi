import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Recebe a senha definida pelo admin
  const { nome, email, cargo, senha } = await req.json()
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

  // Crie o usuário no Auth, usando a senha definida pelo admin
  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password: senha, // senha definida pelo admin
    email_confirm: true,
    user_metadata: {
      full_name: nome,
      display_name: nome,
      must_change_password: true // força troca de senha no primeiro acesso
    },
  })
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }

  // (Opcional, mas recomendado) Garante metadata atualizado
  await supabase.auth.admin.updateUserById(data.user.id, {
    user_metadata: {
      full_name: nome,
      display_name: nome,
      must_change_password: true
    }
  })

  // Crie o usuário na tabela usuarios
  await supabase.from('usuarios').insert({
    id: data.user.id,
    nome,
    cargo,
    permissoes: {},
  })

  return new Response(JSON.stringify({ success: true }), { status: 200 })
})